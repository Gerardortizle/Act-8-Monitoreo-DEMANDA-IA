# Act 8 · Monitoreo DEMANDA-IA

Monitorización proactiva, alertas inteligentes y respuesta automatizada para **DEMANDA-IA**, el pronóstico nocturno de demanda por SKU y sucursal de *Farmacias Occidente Salud* (empresa ficticia, 140 sucursales).

**Actividad 8 · Gestión de proyectos de inteligencia artificial · Universidad Tecmilenio**
José Gerardo Ortiz Leñero (AL07182099) · Profesora: Ing. Tania Judith Mendoza Torres

La estructura sigue el [starter de la Actividad 8](https://github.com/MinaNik229/tema12-mlflow-colab/tree/main/demostraciones_t19_t20/actividad8_observabilidad_starter), adaptado a un proyecto de pronóstico de demanda.

---

## 1. Qué hace

El script simula 30 días de operación (1 al 30 de octubre de 2026) con una muestra de 20 sucursales y 60 SKU (1,200 series) y recorre el flujo completo:

```text
histórico sintético de ventas
   ↓
entrenamiento y registro de versiones (MLflow Tracking + Model Registry)
   ↓
operación: batch nocturno 01:00 + API intradía + evaluación de calidad 06:00
   ↓
métricas + logs JSON + trazas OpenTelemetry
   ↓
data drift (PSI, Kolmogorov-Smirnov, anomalía de temperatura)
   ↓
SLO y presupuestos de error → alertas por burn rate (P1 a P3)
   ↓
incidente → runbook ejecutado por el Responder
   ↓
escalamiento / rollback / corrección / reentrenamiento + canary
   ↓
evidencia: tableros, reportes, informes de incidente y artefactos en MLflow
```

Incidentes que se inyectan en el código (no en los datos de salida):

| Incidente | Qué pasa | Runbook |
|---|---|---|
| INC-2026-10-01 | El ERP lanza un recálculo masivo por `/forecast/bulk`; la API se satura | RB-01 |
| INC-2026-10-02 | Se despliega v3 con la columna `promo` en ceros por un error de pipeline | RB-02 |
| INC-2026-10-03 | Frente frío (anomalía de −10.5 °C) y campaña respiratoria: data drift | RB-03 |

---

## 2. Estructura

```text
Act-8-Monitoreo-DEMANDA-IA/
├── README.md
├── requirements.txt              # versiones usadas en la corrida local (Python 3.13)
├── demo.ps1 / demo.sh            # atajos: setup, run, ui, clean
├── src/
│   └── Act__8__Monitoreo_DEMANDA-IA_JGOL.py      # script completo (monitor + dashboard + incidentes)
├── notebooks/
│   └── Act__8__Monitoreo_DEMANDA-IA_JGOL.ipynb   # mismo código, con las salidas de la corrida local; corre en Colab
├── config/                       # SLO, reglas de alerta, Prometheus y Alertmanager
├── runbooks/                     # RB-01 a RB-04
├── docs/                         # entregables en PDF y guía de la rúbrica
└── outputs/README.md             # qué genera la ejecución (en demanda_ia_obs/, excluida de Git)
```

Equivalencia con los scripts del starter: todo vive en un solo archivo, organizado por secciones.

| Starter | En este repositorio (`src/Act__8__Monitoreo_DEMANDA-IA_JGOL.py`) |
|---|---|
| `data/generate_demo_data.py` | Sección 2: histórico sintético de ventas por SKU y sucursal |
| `src/monitor.py` | Secciones 4 a 7 y 9: instrumentación, SLO, motor de alertas, monitor de drift y simulación |
| `src/simulate_incidents.py` | Secciones 8 y 9: el `Responder` que ejecuta los runbooks y la inyección de los tres incidentes |
| `src/dashboard.py` | Sección 11: los ocho tableros |
| `config/monitoring_config.json` | `config/slo_alertas.yaml` |
| `runbooks/RUNBOOK_TEMPLATE.md` | `runbooks/RB-01` a `RB-04` |

---

## 3. Cómo ejecutarlo

### Windows / PowerShell

```powershell
git clone https://github.com/gerardortizle/Act-8-Monitoreo-DEMANDA-IA.git
cd Act-8-Monitoreo-DEMANDA-IA
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\demo.ps1 setup      # crea .venv e instala requirements.txt
.\demo.ps1 run        # ejecuta la simulación (5 a 10 min)
.\demo.ps1 ui         # levanta MLflow en http://localhost:5000
```

### macOS / Linux

```bash
git clone https://github.com/gerardortizle/Act-8-Monitoreo-DEMANDA-IA.git
cd Act-8-Monitoreo-DEMANDA-IA
bash demo.sh setup
bash demo.sh run
bash demo.sh ui
```

Sin los atajos, el equivalente es crear el entorno virtual, `pip install -r requirements.txt` y `python src/Act__8__Monitoreo_DEMANDA-IA_JGOL.py` desde la raíz del repositorio.

Para volver a ejecutar, aparta primero la corrida anterior con `.\demo.ps1 clean` (o `bash demo.sh clean`); de lo contrario el Model Registry acumula versiones duplicadas.

### Google Colab

Abre `notebooks/Act__8__Monitoreo_DEMANDA-IA_JGOL.ipynb` en Colab y usa *Entorno de ejecución → Ejecutar todas*. La primera celda instala lo que falta y la sección 13 abre MLflow dentro de Colab.

---

## 4. Qué ver en MLflow

Abre `http://localhost:5000` y elige **Model training** (no GenAI).

| Dónde | Qué muestra |
|---|---|
| Experimento `DEMANDA-IA/entrenamiento` | Corridas `train-v1` a `train-v4` con parámetros, métricas de validación y compuerta |
| Model registry → `demanda-ia-forecaster` | Versiones 1 a 4; alias `champion` = v4 y `previous` = v2; v3 etiquetada `rechazado-rollback` |
| Experimento `DEMANDA-IA/monitoreo-produccion` → run `produccion-2026-10` | Métricas por hora y por día (filtros `api_`, `modelo_`, `drift_`) y artefactos: config, tableros, logs, trazas y reportes |
| Runs anidados `INC-2026-10-01` a `INC-2026-10-03` | MTTD, MTTR, pasos del runbook y el JSON con la bitácora del incidente |

---

## 5. Resultados esperados

La simulación usa semilla fija y el reloj simulado en UTC, así que estos valores deben repetirse en cualquier equipo:

| Indicador | Resultado |
|---|---|
| Notificaciones enviadas | 4 (contra 193 con reglas de umbral fijo, 97.9 % menos ruido) |
| INC-2026-10-01 | MTTD 10 min, MTTR 25 min |
| INC-2026-10-02 | MTTD 1,740 min (depende de las ventas del día siguiente), rollback en 31 min |
| INC-2026-10-03 | MTTD 138.8 min; 2 días fuera de SLO contra 5 sin respuesta |
| Disponibilidad de la API | 99.84 % (SLO 99.5 %) |
| Solicitudes < 300 ms | 99.68 % (SLO 95 %) |
| Batch publicado antes de 05:00 | 30 de 30 noches |
| Días con WMAPE ≤ 32 % | 26 de 29; presupuesto de calidad agotado (0 %) |

La relación de cada resultado con la rúbrica está en [`docs/RUBRICA_ACTIVIDAD8_GUIA.md`](docs/RUBRICA_ACTIVIDAD8_GUIA.md).

---

## 6. Entorno de la corrida entregada

Windows 11 · PowerShell · Visual Studio Code · Python 3.13 en entorno virtual · MLflow 3.18 con backend SQLite local. No requiere servicios en la nube.

---

## 7. Declaración de uso de herramientas de inteligencia artificial

Este trabajo se apoyó en Claude (Anthropic) para generar el dataset sintético, escribir el código de la simulación (script y notebook), conciliar los costos con la Actividad 3 y redactar y revisar secciones de la documentación. La ejecución en mi entorno local, la verificación de los resultados, la captura de evidencias en MLflow y la edición final son de mi autoría.
