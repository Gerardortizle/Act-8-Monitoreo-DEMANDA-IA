#!/usr/bin/env bash
# Atajos de ejecución para macOS / Linux
# Uso: bash demo.sh setup | run | ui | clean
set -euo pipefail
STEP="${1:-run}"
PY=".venv/bin/python"
DB="$(pwd)/demanda_ia_obs/mlflow.db"

case "$STEP" in
  setup)
    python3 -m venv .venv
    "$PY" -m pip install --upgrade pip
    "$PY" -m pip install -r requirements.txt
    ;;
  run)
    if [ -d demanda_ia_obs ]; then
      echo "Ya existe demanda_ia_obs. Ejecuta 'bash demo.sh clean' antes para no duplicar versiones en el Model Registry."
      exit 1
    fi
    "$PY" src/Act__8__Monitoreo_DEMANDA-IA_JGOL.py
    ;;
  ui)
    "$PY" -m mlflow server --backend-store-uri "sqlite:///$DB" --port 5000
    ;;
  clean)
    if [ -d demanda_ia_obs ]; then
      DEST="demanda_ia_obs_$(date +%Y%m%d_%H%M%S)"
      mv demanda_ia_obs "$DEST"
      echo "Corrida anterior movida a $DEST"
    fi
    ;;
  *)
    echo "Paso no válido: $STEP (usa setup, run, ui o clean)"; exit 1 ;;
esac
