# config/

Configuración de SLO y alertas que usa la simulación. El script vuelve a generar estos archivos en `demanda_ia_obs/config/` y los registra como artefactos en MLflow; las copias de esta carpeta son para revisarlos sin ejecutar nada.

| Archivo | Para qué sirve | ¿Lo evalúa el script? |
|---|---|---|
| `slo_alertas.yaml` | Los 4 SLO (disponibilidad, latencia, batch y calidad) con su presupuesto de error y objetivo de negocio; las 11 reglas de alerta con severidad y runbook; el control de ruido (agrupación, inhibición, silencios y canales por severidad) | Sí, es la configuración del motor de alertas |
| `prometheus_rules.yaml` | Las reglas de la API escritas como reglas de Prometheus: 8 reglas de registro (proporciones por ventana) y 4 alertas de burn rate con enlace a su runbook | No, es la versión para un clúster real |
| `alertmanager.yaml` | Enrutamiento por severidad (P1 a PagerDuty y Slack, P2 a Slack, P3 a resumen diario), agrupación por servicio y SLO, e inhibición de P2/P3 cuando hay un P1 | No, es la versión para un clúster real |

## SLO definidos

| SLO | Objetivo | Presupuesto de error |
|---|---|---|
| SLO-API-DISP | 99.5 % de solicitudes sin 5xx | 0.5 % de las solicitudes |
| SLO-API-LAT | 95 % de solicitudes < 300 ms | 5 % de solicitudes lentas |
| SLO-BATCH | Pronóstico publicado antes de 05:00 | 1 noche de 30 |
| SLO-CALIDAD | WMAPE ≤ 32 % en 90 % de los días | 3 días de 30 (≈ 129,700 MXN de beneficio en riesgo) |

Los umbrales se calibraron con la línea base de la simulación (WMAPE promedio de 25.7 % en las dos primeras semanas de octubre) y con el caso de negocio de la Actividad 3. La justificación completa está en la sección 3 de `docs/01_documento_tecnico.pdf`.
