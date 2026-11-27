#!/usr/bin/env bash
# =====================================================================
# Configura la observabilidad del microservicio en AWS CloudWatch (IE1/IE3)
#
# Se ejecuta EN la instancia EC2 (vía SSH) desde el job "6 · Deploy AWS EC2",
# antes de levantar los contenedores. Es idempotente: se puede correr en
# cada despliegue y deja todo igual si ya existía.
#
# Uso: bash setup-cloudwatch.sh [correo_alertas] [puerto_gateway]
#
# Qué configura:
#   1. CloudWatch Agent        -> CPU, memoria y disco de la instancia
#   2. Grupos de logs          -> /pokemon/app, /pokemon/gateway, /pokemon/db (7 días)
#   3. Filtros de métricas     -> errores (ERROR, 5xx, 4xx), peticiones y latencia
#   4. Health check (systemd)  -> disponibilidad y uso de las réplicas cada 1 min
#   5. Alarmas + SNS           -> aviso por correo ante caída, errores o recursos altos
#   6. Dashboard               -> "Pokemon-DevOps" (monitoring/dashboard.json)
#
# Usa el rol IAM de la instancia (LabInstanceProfile en AWS Academy).
# Si la instancia no tiene rol, avisa y sale sin error: el despliegue
# continúa, pero sin enviar datos a CloudWatch.
# =====================================================================
set -uo pipefail

ALERT_EMAIL="${1:-}"
PORT="${2:-80}"
APP_DIR="$HOME/pokemon"
MON_DIR="$APP_DIR/monitoring"
NS_APP="Pokemon/App"
DASHBOARD="Pokemon-DevOps"
TOPIC="pokemon-alertas"
MARCA="$APP_DIR/.cloudwatch-enabled"

aviso() { echo "::warning::$*"; }

# ---------------------------------------------------------------------
# 0. Metadatos de la instancia (IMDSv2) y rol IAM
# ---------------------------------------------------------------------
TOKEN=$(curl -s -m 5 -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 300") || TOKEN=""
imds() { curl -s -m 5 -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/meta-data/$1"; }

ROL=$(imds iam/security-credentials/ || true)
if [ -z "$TOKEN" ] || [ -z "$ROL" ] || [[ "$ROL" == *"<"* ]]; then
  aviso "La instancia no tiene un rol IAM asignado: se omite CloudWatch. Asigna LabInstanceProfile en EC2 > Actions > Security > Modify IAM role."
  rm -f "$MARCA"
  exit 0
fi

REGION=$(imds placement/region)
INSTANCE_ID=$(imds instance-id)
export AWS_DEFAULT_REGION="$REGION"
echo "==> Instancia ${INSTANCE_ID} (${REGION}), rol IAM: ${ROL}"

if ! command -v aws > /dev/null 2>&1; then
  echo "==> Instalando AWS CLI"
  if command -v dnf > /dev/null 2>&1; then sudo dnf install -y -q awscli-2 || sudo dnf install -y -q awscli
  else sudo snap install aws-cli --classic; fi
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text) || {
  aviso "El rol IAM no permite usar la API de AWS: se omite CloudWatch"
  rm -f "$MARCA"; exit 0; }

# ---------------------------------------------------------------------
# 1. CloudWatch Agent: métricas del sistema (la memoria no viene por defecto en EC2)
# ---------------------------------------------------------------------
CWA_CTL=/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl
if [ ! -x "$CWA_CTL" ]; then
  echo "==> Instalando CloudWatch Agent"
  if command -v dnf > /dev/null 2>&1; then
    sudo dnf install -y -q amazon-cloudwatch-agent
  else
    ARQ=$(dpkg --print-architecture)
    curl -fsSL -o /tmp/cwagent.deb "https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/${ARQ}/latest/amazon-cloudwatch-agent.deb"
    sudo dpkg -i -E /tmp/cwagent.deb
  fi
fi
sudo install -m 644 "$MON_DIR/cloudwatch-agent.json" /opt/aws/amazon-cloudwatch-agent/etc/pokemon-agent.json
sudo "$CWA_CTL" -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/pokemon-agent.json > /dev/null \
  && echo "CloudWatch Agent activo (namespace Pokemon/EC2)" \
  || aviso "No se pudo iniciar CloudWatch Agent"

# ---------------------------------------------------------------------
# 2. Grupos de logs (los contenedores escriben aquí con el driver awslogs)
# ---------------------------------------------------------------------
echo "==> Grupos de logs"
GRUPOS_OK=1
for g in /pokemon/app /pokemon/gateway /pokemon/db; do
  aws logs create-log-group --log-group-name "$g" 2> /dev/null || true
  if aws logs put-retention-policy --log-group-name "$g" --retention-in-days 7; then
    echo "  $g (retención 7 días)"
  else
    GRUPOS_OK=0
  fi
done

# ---------------------------------------------------------------------
# 3. Filtros de métricas: convierten líneas de log en métricas numéricas
# ---------------------------------------------------------------------
echo "==> Filtros de métricas"
filtro() {  # grupo nombre patrón métrica valor [unidad]
  aws logs put-metric-filter --log-group-name "$1" --filter-name "$2" --filter-pattern "$3" \
    --metric-transformations "metricName=$4,metricNamespace=${NS_APP},metricValue=$5,defaultValue=0${6:+,unit=$6}" \
    && echo "  $2 -> $4" || aviso "No se pudo crear el filtro $2"
}
# Spring Boot: "2026-11-26 10:00:00.123 ERROR [hilo] clase - mensaje"
filtro /pokemon/app     errores-app       '[fecha, hora, nivel=ERROR, ...]' ErroresApp 1 Count
filtro /pokemon/app     advertencias-app  '[fecha, hora, nivel=WARN, ...]'  AdvertenciasApp 1 Count
# Nginx (log en JSON, ver deploy/nginx/default.conf)
filtro /pokemon/gateway peticiones        '{ $.status > 0 }'                           Peticiones 1 Count
filtro /pokemon/gateway errores-5xx       '{ $.status >= 500 }'                        Errores5xx 1 Count
filtro /pokemon/gateway errores-4xx       '{ ($.status >= 400) && ($.status < 500) }' Errores4xx 1 Count
# La latencia no lleva defaultValue 0 (bajaría el promedio artificialmente)
aws logs put-metric-filter --log-group-name /pokemon/gateway --filter-name latencia \
  --filter-pattern '{ $.rt >= 0 }' \
  --metric-transformations "metricName=LatenciaGateway,metricNamespace=${NS_APP},metricValue=\$.rt,unit=Seconds" \
  && echo "  latencia -> LatenciaGateway" || aviso "No se pudo crear el filtro de latencia"

# ---------------------------------------------------------------------
# 4. Health check cada minuto (disponibilidad + uso de las réplicas)
# ---------------------------------------------------------------------
echo "==> Health check (systemd timer)"
sudo install -m 755 "$MON_DIR/pokemon-healthcheck.sh" /usr/local/bin/pokemon-healthcheck.sh
printf 'AWS_REGION=%s\nPORT=%s\n' "$REGION" "$PORT" | sudo tee /etc/pokemon-healthcheck.env > /dev/null
sudo tee /etc/systemd/system/pokemon-healthcheck.service > /dev/null <<'EOF'
[Unit]
Description=Health check de pokemon-service hacia CloudWatch
After=docker.service network-online.target

[Service]
Type=oneshot
EnvironmentFile=/etc/pokemon-healthcheck.env
ExecStart=/usr/local/bin/pokemon-healthcheck.sh
EOF
sudo tee /etc/systemd/system/pokemon-healthcheck.timer > /dev/null <<'EOF'
[Unit]
Description=Ejecuta el health check de pokemon-service cada minuto

[Timer]
OnBootSec=1min
OnUnitActiveSec=1min
AccuracySec=5s

[Install]
WantedBy=timers.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now pokemon-healthcheck.timer > /dev/null 2>&1 \
  && echo "  pokemon-healthcheck.timer activo" || aviso "No se pudo activar el health check"

# ---------------------------------------------------------------------
# 5. Alarmas y notificaciones (SNS)
# ---------------------------------------------------------------------
echo "==> Alarmas"
TOPIC_ARN=$(aws sns create-topic --name "$TOPIC" --query TopicArn --output text 2> /dev/null || true)
ACCIONES=()
if [ -n "$TOPIC_ARN" ] && [ "$TOPIC_ARN" != "None" ]; then
  ACCIONES=(--alarm-actions "$TOPIC_ARN" --ok-actions "$TOPIC_ARN")
  if [ -n "$ALERT_EMAIL" ]; then
    YA=$(aws sns list-subscriptions-by-topic --topic-arn "$TOPIC_ARN" \
      --query "Subscriptions[?Endpoint=='${ALERT_EMAIL}'] | length(@)" --output text 2> /dev/null || echo 0)
    if [ "$YA" = "0" ]; then
      aws sns subscribe --topic-arn "$TOPIC_ARN" --protocol email --notification-endpoint "$ALERT_EMAIL" > /dev/null \
        && echo "  Suscripción enviada: confirma el correo que llegó a la casilla de alertas"
    fi
  fi
else
  aviso "No se pudo crear el tema SNS: las alarmas se crean sin notificación"
fi

alarma() {  # nombre descripción [args de put-metric-alarm...]
  local nombre="$1" desc="$2"; shift 2
  aws cloudwatch put-metric-alarm --alarm-name "$nombre" --alarm-description "$desc" \
    "${ACCIONES[@]}" "$@" && echo "  $nombre" || aviso "No se pudo crear la alarma $nombre"
}
alarma Pokemon-Disponibilidad "El health check falló 2 minutos seguidos: el servicio no responde" \
  --namespace "$NS_APP" --metric-name Disponibilidad --statistic Minimum \
  --period 60 --evaluation-periods 2 --threshold 1 --comparison-operator LessThanThreshold \
  --treat-missing-data notBreaching
alarma Pokemon-Errores5xx "5 o más respuestas 5xx en 5 minutos" \
  --namespace "$NS_APP" --metric-name Errores5xx --statistic Sum \
  --period 300 --evaluation-periods 1 --threshold 5 --comparison-operator GreaterThanOrEqualToThreshold \
  --treat-missing-data notBreaching
alarma Pokemon-ErroresApp "5 o más errores (ERROR) en los logs de la app en 5 minutos" \
  --namespace "$NS_APP" --metric-name ErroresApp --statistic Sum \
  --period 300 --evaluation-periods 1 --threshold 5 --comparison-operator GreaterThanOrEqualToThreshold \
  --treat-missing-data notBreaching
alarma Pokemon-CPU-Alta "CPU de la instancia sobre 80% por 10 minutos" \
  --namespace AWS/EC2 --metric-name CPUUtilization --dimensions "Name=InstanceId,Value=${INSTANCE_ID}" \
  --statistic Average --period 300 --evaluation-periods 2 --threshold 80 \
  --comparison-operator GreaterThanThreshold --treat-missing-data notBreaching
alarma Pokemon-Memoria-Alta "Memoria de la instancia sobre 85% por 10 minutos" \
  --namespace Pokemon/EC2 --metric-name mem_used_percent --dimensions "Name=InstanceId,Value=${INSTANCE_ID}" \
  --statistic Average --period 300 --evaluation-periods 2 --threshold 85 \
  --comparison-operator GreaterThanThreshold --treat-missing-data notBreaching

# ---------------------------------------------------------------------
# 6. Dashboard (definido como código en monitoring/dashboard.json)
# ---------------------------------------------------------------------
echo "==> Dashboard"
sed -e "s/__REGION__/${REGION}/g" -e "s/__INSTANCE_ID__/${INSTANCE_ID}/g" -e "s/__ACCOUNT_ID__/${ACCOUNT_ID}/g" \
  "$MON_DIR/dashboard.json" > /tmp/pokemon-dashboard.json
if aws cloudwatch put-dashboard --dashboard-name "$DASHBOARD" \
     --dashboard-body file:///tmp/pokemon-dashboard.json > /tmp/pokemon-dashboard.out; then
  echo "  https://${REGION}.console.aws.amazon.com/cloudwatch/home?region=${REGION}#dashboards/dashboard/${DASHBOARD}"
  grep -q '"DashboardValidationMessages": \[\]' /tmp/pokemon-dashboard.out || cat /tmp/pokemon-dashboard.out
else
  aviso "No se pudo publicar el dashboard"
fi

# ---------------------------------------------------------------------
# Marca para ec2-deploy.sh: enviar los logs de los contenedores a CloudWatch
# ---------------------------------------------------------------------
if [ "$GRUPOS_OK" = "1" ]; then
  echo "AWS_REGION=${REGION}" > "$MARCA"
  echo "CloudWatch configurado: los contenedores enviarán sus logs a /pokemon/*"
else
  rm -f "$MARCA"
  aviso "No se pudieron preparar los grupos de logs: los contenedores usarán logs locales"
fi
