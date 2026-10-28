#!/usr/bin/env bash
# =====================================================================
# Smoke tests post-despliegue
#
# Verifica, contra el entorno ya desplegado con Docker Compose, que:
#   1. El servicio está sano (actuator health)
#   2. La versión desplegada corresponde al commit esperado (trazabilidad)
#   3. El CRUD completo funciona de punta a punta (gateway -> app -> BD)
#   4. El gateway reparte la carga entre las réplicas
#
# Uso:  BASE_URL=http://localhost:8080 EXPECTED_COMMIT=<sha> ./scripts/smoke-test.sh
# Sale con código != 0 ante cualquier falla, lo que detiene el pipeline.
# =====================================================================
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8080}"
EXPECTED_COMMIT="${EXPECTED_COMMIT:-}"
EXPECTED_REPLICAS="${EXPECTED_REPLICAS:-1}"
NAME="smoke-$(date +%s)"

pass() { echo "  [OK]   $*"; }
fail() { echo "  [FAIL] $*" >&2; exit 1; }

# Ejecuta una petición y devuelve "<código_http>" en la última línea
request() {
  local method="$1" path="$2" body="${3:-}"
  if [[ -n "$body" ]]; then
    curl -s -o /tmp/smoke_body -w '%{http_code}' -X "$method" \
      -H 'Content-Type: application/json' -d "$body" "${BASE_URL}${path}"
  else
    curl -s -o /tmp/smoke_body -w '%{http_code}' -X "$method" "${BASE_URL}${path}"
  fi
}

expect_status() {
  local expected="$1" actual="$2" what="$3"
  if [[ "$actual" == "$expected" ]]; then
    pass "$what -> HTTP $actual"
  else
    cat /tmp/smoke_body >&2 || true
    fail "$what -> esperado $expected, recibido $actual"
  fi
}

echo "Smoke tests contra ${BASE_URL}"

# 1. Salud
status=$(request GET /actuator/health)
expect_status 200 "$status" "GET /actuator/health"
grep -q '"UP"' /tmp/smoke_body || fail "health no está UP"

# 2. Trazabilidad: commit desplegado
status=$(request GET /actuator/info)
expect_status 200 "$status" "GET /actuator/info"
deployed_commit=$(jq -r '.app.commit' /tmp/smoke_body)
echo "         commit desplegado: ${deployed_commit}"
if [[ -n "$EXPECTED_COMMIT" ]]; then
  if [[ "$deployed_commit" == "$EXPECTED_COMMIT" ]]; then
    pass "la versión desplegada coincide con el commit ${EXPECTED_COMMIT:0:7}"
  else
    fail "commit desplegado (${deployed_commit}) != esperado (${EXPECTED_COMMIT})"
  fi
fi

# 3. CRUD de punta a punta
status=$(request GET /api/pokemons)
expect_status 200 "$status" "GET /api/pokemons"

status=$(request POST /api/pokemons "{\"name\":\"${NAME}\",\"type\":\"Test\",\"level\":5}")
expect_status 201 "$status" "POST /api/pokemons"
id=$(jq -r '.id' /tmp/smoke_body)

status=$(request GET "/api/pokemons/${id}")
expect_status 200 "$status" "GET /api/pokemons/${id}"

status=$(request GET "/api/pokemons/name/${NAME}")
expect_status 200 "$status" "GET /api/pokemons/name/${NAME}"

status=$(request PUT "/api/pokemons/${id}" '{"level":10}')
expect_status 200 "$status" "PUT /api/pokemons/${id}"
[[ "$(jq -r '.level' /tmp/smoke_body)" == "10" ]] || fail "el nivel no se actualizó"

status=$(request POST /api/pokemons '{"name":"","type":"Test","level":0}')
expect_status 400 "$status" "POST inválido es rechazado"

status=$(request DELETE "/api/pokemons/${id}")
expect_status 204 "$status" "DELETE /api/pokemons/${id}"

status=$(request GET "/api/pokemons/${id}")
expect_status 404 "$status" "GET tras eliminar"

# 4. Balanceo de carga entre réplicas
declare -A seen=()
for _ in $(seq 1 20); do
  addr=$(curl -s -o /dev/null -D - "${BASE_URL}/actuator/health" \
         | awk -F': ' 'tolower($1)=="x-upstream-addr"{print $2}' | tr -d '\r')
  if [[ -n "$addr" ]]; then seen["$addr"]=1; fi
done
echo "         réplicas que respondieron: ${#seen[@]} (${!seen[*]})"
if (( ${#seen[@]} >= EXPECTED_REPLICAS )); then
  pass "el gateway reparte carga entre ${#seen[@]} réplica(s)"
else
  fail "solo respondieron ${#seen[@]} réplica(s), se esperaban ${EXPECTED_REPLICAS}"
fi

echo "Todos los smoke tests pasaron."
