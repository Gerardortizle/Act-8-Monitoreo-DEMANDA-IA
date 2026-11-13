# outputs/

El script no escribe aquí: guarda todo en la carpeta `demanda_ia_obs/`, que se crea en la raíz del repositorio al ejecutarlo. Esa carpeta está excluida de Git para que cada quien genere su propia evidencia.

Contenido de `demanda_ia_obs/` después de una corrida:

| Ruta | Qué contiene |
|---|---|
| `mlflow.db`, `mlartifacts/` | Base de MLflow (Tracking y Model Registry) y artefactos de cada run |
| `config/` | `slo_alertas.yaml`, `prometheus_rules.yaml`, `alertmanager.yaml` (las mismas de `config/` del repositorio) |
| `figs/` | 8 tableros PNG: tablero operativo, API, zoom de INC-01, WMAPE, PSI, presupuesto de error, ruido de alertas y trazas |
| `logs/demanda_ia.jsonl` | Logs estructurados en JSON (batch, API, alertas, incidentes y pasos de runbook) |
| `traces/spans.jsonl` | Spans de OpenTelemetry con muestreo por cola |
| `reports/` | CSV de la API cada 5 min, calidad diaria, drift diario, batch nocturno y alertas |
| `incidents/` | Un JSON por incidente con su línea de tiempo, MTTD y MTTR |

Equivalencia con el starter de referencia: `monitoring_summary.json` ≈ `reports/`, `alerts.json` ≈ `reports/alertas_*.csv`, `monitoring_log.jsonl` ≈ `logs/demanda_ia.jsonl`, `traces.jsonl` ≈ `traces/spans.jsonl` y `dashboard.png` ≈ `figs/dashboard_operativo.png`.
