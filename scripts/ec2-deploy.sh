#!/usr/bin/env bash
# =====================================================================
# Despliegue en la instancia EC2 (se ejecuta EN la instancia, vía SSH,
# desde el job "6 · Deploy AWS EC2" del pipeline).
#
# Uso: bash ec2-deploy.sh --instalar                      (solo instala Docker)
#      bash ec2-deploy.sh <imagen> <commit> <réplicas> <puerto> <supabase|local>
#
# - Instala Docker y Docker Compose si la instancia no los tiene
#   (Amazon Linux o Ubuntu).
# - Mantiene la contraseña de la base entre despliegues (vive en .env
#   de la instancia, nunca en el repositorio).
# - Levanta el mismo docker-compose.yml que se usa en local y en staging,
#   con la imagen EXACTA que pasó las pruebas y el escaneo.
# =====================================================================
set -euo pipefail

instalar_docker() {
echo "==> Verificando Docker"
if ! command -v docker > /dev/null 2>&1; then
  echo "Docker no está instalado; instalando..."
  if command -v apt-get > /dev/null 2>&1; then
    curl -fsSL https://get.docker.com | sudo sh
  elif command -v dnf > /dev/null 2>&1; then
    sudo dnf install -y docker
  else
    sudo yum install -y docker
  fi
  sudo systemctl enable --now docker
fi

if ! sudo docker compose version > /dev/null 2>&1; then
  echo "Docker Compose no está instalado; instalando plugin..."
  sudo mkdir -p /usr/local/lib/docker/cli-plugins
  sudo curl -fsSL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" \
    -o /usr/local/lib/docker/cli-plugins/docker-compose
  sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
fi
sudo docker compose version
}

instalar_docker
if [ "${1:-}" = "--instalar" ]; then
  exit 0
fi

IMAGE="$1"
COMMIT="$2"
REPLICAS="${3:-2}"
PORT="${4:-80}"
DB_MODE="${5:-local}"
APP_DIR="$HOME/pokemon"

echo "==> Preparando variables del entorno"
cd "$APP_DIR"
touch .env
chmod 600 .env
# La contraseña de la base se genera UNA vez y se conserva: el volumen de
# PostgreSQL ya quedó inicializado con ella.
if ! grep -q '^POSTGRES_PASSWORD=' .env; then
  echo "POSTGRES_PASSWORD=$(head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n')" >> .env
fi
sed -i '/^\(APP_IMAGE\|DEPLOY_ENV\|APP_REPLICAS\|GIT_COMMIT\|GATEWAY_PORT\)=/d' .env
{
  echo "APP_IMAGE=${IMAGE}"
  echo "DEPLOY_ENV=aws-ec2"
  echo "APP_REPLICAS=${REPLICAS}"
  echo "GIT_COMMIT=${COMMIT}"
  echo "GATEWAY_PORT=${PORT}"
} >> .env

# Base de datos: Supabase (nube) o PostgreSQL local de la instancia
COMPOSE=(sudo docker compose -f docker-compose.yml)
sed -i '/^SUPABASE_DB_/d' .env
if [ "$DB_MODE" = "supabase" ] && [ -f .env.supabase ]; then
  cat .env.supabase >> .env
  rm -f .env.supabase
  touch .use-supabase
  COMPOSE+=(-f docker-compose.supabase.yml)
  echo "Base de datos: Supabase"
else
  rm -f .use-supabase
  echo "Base de datos: PostgreSQL local"
fi

echo "==> Descargando imagen ${IMAGE}"
"${COMPOSE[@]}" pull app
# La sesión en GHCR solo se necesitaba para descargar la imagen
sudo docker logout ghcr.io > /dev/null 2>&1 || true

echo "==> Desplegando"
"${COMPOSE[@]}" up -d --no-build --remove-orphans --wait --wait-timeout 300
"${COMPOSE[@]}" ps

echo "==> Limpiando imágenes antiguas"
sudo docker image prune -f > /dev/null

echo "Despliegue en EC2 completado: ${IMAGE}"
