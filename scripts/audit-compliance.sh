#!/usr/bin/env bash
# =====================================================================
# Auditoría automatizada de cumplimiento (IE5 / IE6)
#
# Revisa políticas de seguridad y calidad del repositorio que no cubren
# SonarCloud ni las pruebas. Si alguna política CRÍTICA no se cumple,
# termina con código 1 y el pipeline se detiene (no se construye la
# imagen ni se despliega).
#
# Uso:  bash scripts/audit-compliance.sh        (desde la raíz del repo)
# En GitHub Actions el resultado queda como tabla en el Job Summary.
# =====================================================================
set -uo pipefail

FALLAS=0
AVISOS=0
FILAS=()

ok()    { FILAS+=("| ✅ | $1 | $2 |"); echo "  [OK]    $1: $2"; }
falla() { FILAS+=("| ❌ | $1 | $2 |"); echo "  [FALLA] $1: $2" >&2; FALLAS=$((FALLAS + 1)); }
aviso() { FILAS+=("| ⚠️ | $1 | $2 |"); echo "  [AVISO] $1: $2"; AVISOS=$((AVISOS + 1)); }

echo "==> Auditoría de cumplimiento"

# Archivos versionados (en CI) o del directorio (si no hay git)
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  ARCHIVOS=$(git ls-files)
else
  ARCHIVOS=$(find . -type f -not -path './.git/*' -not -path './target/*' | sed 's|^\./||')
fi

# ---------------------------------------------------------------------
# P1. Sin secretos ni credenciales versionados
# ---------------------------------------------------------------------
SENSIBLES=$(printf '%s\n' "$ARCHIVOS" | grep -E '(^|/)\.env(\..+)?$|\.pem$|\.key$|\.p12$|\.pfx$|(^|/)id_(rsa|ed25519)$|(^|/)credentials(\.json)?$' | grep -v '\.env\.example$' || true)
if [ -z "$SENSIBLES" ]; then
  ok "P1 Secretos" "No hay archivos .env, llaves ni credenciales en el repositorio"
else
  falla "P1 Secretos" "Archivos sensibles versionados: $(echo "$SENSIBLES" | paste -sd ', ' -)"
fi

for patron in '.env' '*.pem'; do
  if grep -qxF "$patron" .gitignore 2>/dev/null; then
    ok "P2 .gitignore" "Ignora $patron"
  else
    falla "P2 .gitignore" "Falta '$patron' en .gitignore"
  fi
done

# Contraseñas escritas directamente en la configuración de Spring
if grep -nE '^\s*password:\s*[^$[:space:]]' src/main/resources/application*.yml 2>/dev/null; then
  falla "P3 Configuración" "Hay contraseñas fijas en application.yml (deben venir de variables de entorno)"
else
  ok "P3 Configuración" "Las credenciales de la base se inyectan por variables de entorno"
fi

# ---------------------------------------------------------------------
# P4. Contenedor seguro
# ---------------------------------------------------------------------
ULTIMO_USER=$(grep -E '^\s*USER\s+' Dockerfile | tail -1 | awk '{print $2}')
if [ -n "$ULTIMO_USER" ] && [[ ! "$ULTIMO_USER" =~ ^(root|0)(:|$) ]]; then
  ok "P4 Dockerfile" "La aplicación corre con usuario sin privilegios ($ULTIMO_USER)"
else
  falla "P4 Dockerfile" "La imagen final corre como root (falta USER sin privilegios)"
fi

if grep -E '^\s*FROM\s+' Dockerfile | awk '{print $2}' | grep -qE '(:latest$|^[^:@]+$)'; then
  falla "P5 Dockerfile" "Hay imágenes base sin versión fija o con :latest"
else
  ok "P5 Dockerfile" "Todas las imágenes base tienen versión fija"
fi

if grep -qE '^\s*HEALTHCHECK' Dockerfile; then
  ok "P6 Dockerfile" "La imagen define HEALTHCHECK"
else
  aviso "P6 Dockerfile" "La imagen no define HEALTHCHECK"
fi

# ---------------------------------------------------------------------
# P7. Orquestación segura (Docker Compose)
# ---------------------------------------------------------------------
if grep -qE '^\s*privileged:\s*true' docker-compose*.yml; then
  falla "P7 Compose" "Hay contenedores con privileged: true"
else
  ok "P7 Compose" "Ningún contenedor corre en modo privilegiado"
fi

PUERTOS=$(grep -cE '^\s*ports:' docker-compose.yml || true)
if [ "$PUERTOS" -le 1 ]; then
  ok "P8 Compose" "Solo el gateway publica puertos; app y base de datos quedan en red interna"
else
  falla "P8 Compose" "Hay $PUERTOS servicios publicando puertos (solo el gateway debería)"
fi

# ---------------------------------------------------------------------
# P9. Política de calidad: cobertura mínima
# ---------------------------------------------------------------------
MINIMO=$(grep -oP '<jacoco.minimum.line.coverage>\K[0-9.]+' pom.xml || echo 0)
if awk -v m="$MINIMO" 'BEGIN { exit !(m >= 0.80) }'; then
  ok "P9 Cobertura" "El build exige al menos $(awk -v m="$MINIMO" 'BEGIN { printf "%d", m * 100 }')% de cobertura de líneas"
else
  falla "P9 Cobertura" "La cobertura mínima configurada ($MINIMO) es menor a 0.80"
fi

# ---------------------------------------------------------------------
# P10. Pipeline seguro
# ---------------------------------------------------------------------
if grep -qE 'pull_request_target' .github/workflows/*.yml; then
  falla "P10 Pipeline" "Se usa pull_request_target (expone secretos a código externo)"
else
  ok "P10 Pipeline" "No se usa pull_request_target"
fi

for wf in .github/workflows/*.yml; do
  if grep -qE '^permissions:' "$wf"; then
    ok "P11 Pipeline" "$(basename "$wf") define permisos mínimos (permissions)"
  else
    falla "P11 Pipeline" "$(basename "$wf") no define 'permissions' (el token tendría permisos amplios)"
  fi
done

# ---------------------------------------------------------------------
# P12. Archivos obligatorios del proyecto
# ---------------------------------------------------------------------
for f in README.md Dockerfile .env.example .github/dependabot.yml .gitleaks.toml; do
  if [ -f "$f" ]; then
    ok "P12 Archivos" "Existe $f"
  else
    falla "P12 Archivos" "Falta $f"
  fi
done

# ---------------------------------------------------------------------
# Resultado
# ---------------------------------------------------------------------
echo
echo "Resultado: ${FALLAS} falla(s), ${AVISOS} aviso(s)"

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "## Auditoría de cumplimiento"
    echo
    echo "| Estado | Política | Detalle |"
    echo "|---|---|---|"
    printf '%s\n' "${FILAS[@]}"
    echo
    if [ "$FALLAS" -gt 0 ]; then
      echo "**❌ ${FALLAS} política(s) no se cumplen: el pipeline se detiene.**"
    else
      echo "**✅ Todas las políticas críticas se cumplen.**"
    fi
  } >> "$GITHUB_STEP_SUMMARY"
fi

[ "$FALLAS" -eq 0 ]
