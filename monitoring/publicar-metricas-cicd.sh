#!/usr/bin/env bash
# =====================================================================
# Publica en CloudWatch (namespace Pokemon/CICD) las métricas del pipeline
#
# Lo llama el job "6 · Deploy AWS EC2" al final de cada despliegue a
# producción. Se ejecuta EN la instancia para usar su rol IAM: así el
# pipeline no necesita llaves de AWS (las de AWS Academy caducan).
#
# Uso: bash publicar-metricas-cicd.sh Nombre=valor:Unidad [Nombre=valor:Unidad ...]
#   ej: bash publicar-metricas-cicd.sh TiempoDespliegue=95:Seconds CoberturaPruebas=91.3:Percent
# Las métricas sin valor (vacías) se omiten.
# =====================================================================
set -euo pipefail

if [ ! -f "$HOME/pokemon/.cloudwatch-enabled" ]; then
  echo "CloudWatch no está habilitado en la instancia: no se publican métricas del pipeline"
  exit 0
fi
# shellcheck disable=SC1091
source "$HOME/pokemon/.cloudwatch-enabled"   # define AWS_REGION

DATOS=()
for par in "$@"; do
  nombre="${par%%=*}"
  resto="${par#*=}"
  valor="${resto%%:*}"
  unidad="${resto#*:}"
  if [[ "$valor" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    DATOS+=("MetricName=${nombre},Value=${valor},Unit=${unidad}")
    echo "  ${nombre} = ${valor} ${unidad}"
  else
    echo "  ${nombre}: sin valor, se omite"
  fi
done

if [ "${#DATOS[@]}" -gt 0 ]; then
  aws cloudwatch put-metric-data --region "$AWS_REGION" --namespace "Pokemon/CICD" --metric-data "${DATOS[@]}"
  echo "Métricas del pipeline publicadas en CloudWatch (Pokemon/CICD)"
fi
