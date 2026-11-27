#!/usr/bin/env bash
# =====================================================================
# Chequeo de disponibilidad y uso de recursos del microservicio
#
# Lo ejecuta systemd cada minuto en la instancia EC2
# (pokemon-healthcheck.timer, instalado por setup-cloudwatch.sh) y publica
# en CloudWatch, namespace Pokemon/App:
#
#   Disponibilidad            1 si /actuator/health responde 200, 0 si no
#   TiempoRespuestaMs         latencia del health check a través del gateway
#   ReplicasSanas             réplicas de la app con healthcheck "healthy"
#   CPUContenedoresApp        % de CPU que usan las réplicas (suma)
#   MemoriaContenedoresAppMB  memoria que usan las réplicas (suma, MB)
#
# Usa el rol IAM de la instancia: no necesita llaves de acceso.
# Variables (de /etc/pokemon-healthcheck.env): AWS_REGION, PORT
# =====================================================================
set -uo pipefail

PORT="${PORT:-80}"
NAMESPACE="Pokemon/App"
: "${AWS_REGION:?Falta AWS_REGION}"

# 1) Disponibilidad y tiempo de respuesta (a través del gateway, como un cliente)
RESULTADO=$(curl -s -o /dev/null -m 10 -w '%{http_code} %{time_total}' \
  "http://127.0.0.1:${PORT}/actuator/health" 2>/dev/null) || true
CODIGO=$(echo "${RESULTADO:-000 10}" | awk '{print $1}')
SEGUNDOS=$(echo "${RESULTADO:-000 10}" | awk '{print $2}')
if [ "$CODIGO" = "200" ]; then DISPONIBLE=1; else DISPONIBLE=0; fi
MS=$(awk -v s="${SEGUNDOS:-10}" 'BEGIN { printf "%.0f", s * 1000 }')

# 2) Réplicas sanas y consumo de los contenedores de la app
SANAS=$(docker ps --filter "name=pokemon-app" --filter "health=healthy" -q 2>/dev/null | wc -l)
read -r CPU MEM < <(docker stats --no-stream --format '{{.Name}} {{.CPUPerc}} {{.MemUsage}}' 2>/dev/null \
  | awk '$1 ~ /^pokemon-app/ {
      gsub("%", "", $2); cpu += $2
      v = $3; mb = v + 0
      if (v ~ /GiB$/) mb *= 1024; else if (v ~ /KiB$/) mb /= 1024; else if (v ~ /B$/ && v !~ /iB$/) mb /= 1048576
      mem += mb
    } END { printf "%.2f %.1f\n", cpu, mem }')

aws cloudwatch put-metric-data --region "$AWS_REGION" --namespace "$NAMESPACE" --metric-data \
  "MetricName=Disponibilidad,Value=${DISPONIBLE},Unit=Count" \
  "MetricName=TiempoRespuestaMs,Value=${MS},Unit=Milliseconds" \
  "MetricName=ReplicasSanas,Value=${SANAS},Unit=Count" \
  "MetricName=CPUContenedoresApp,Value=${CPU:-0},Unit=Percent" \
  "MetricName=MemoriaContenedoresAppMB,Value=${MEM:-0},Unit=Megabytes"

echo "health=${CODIGO} disponible=${DISPONIBLE} ms=${MS} replicas_sanas=${SANAS} cpu=${CPU:-0}% mem=${MEM:-0}MB"
