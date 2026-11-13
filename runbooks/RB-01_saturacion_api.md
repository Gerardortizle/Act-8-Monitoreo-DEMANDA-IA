# Runbook RB-01 · Saturación o caída de forecast-api

## 1. Señal que activa el runbook
- Métrica: burn rate de los SLO de la API (disponibilidad y latencia) en ventana larga y corta.
- Reglas: `API-DISP-RAPIDA` (≥ 14.4 en 1 h y en 5 min), `API-DISP-LENTA` (≥ 6 en 6 h y en 30 min), `API-LAT-RAPIDA` (≥ 14.4 en 1 h y en 5 min).
- Severidad: P1 (disponibilidad rápida) o P2.

## 2. Impacto esperado
Compradores y ERP no pueden recalcular sugeridos de compra durante el día y aumentan los traslados urgentes entre sucursales (beneficio B04 de la Actividad 3).

## 3. Diagnóstico inicial
1. Abrir las trazas de la última hora y ver qué span domina (`feature_store.get`, `model.predict`).
2. Revisar utilización, réplicas y reinicios OOMKilled.
3. Revisar el hit ratio de la caché del feature store.

## 4. Acción principal
| Paso | Tipo | Acción |
|---|---|---|
| 1 | Auto | Leer trazas y ubicar el span dominante |
| 2 | Auto | Escalar forecast-api a 8 réplicas (tope de 10) |
| 3 | Auto | Activar rate limiting en `/forecast/bulk` (50 req/s por cliente) |
| 4 | Auto | Recalentar la caché con el 20 % de SKU de mayor venta |
| 5 | Auto | Verificar 15 min con burn rate < 1 en ventanas cortas |
| 6 | Manual | Acordar con TI que el recálculo masivo use la ventana nocturna |

Escalamiento: si en 20 min el burn rate de 5 min no baja de 14.4, se llama al Arquitecto de TI/IA y se evalúa cambiar de región (riesgo R11).

## 5. Validación de recuperación
Burn rate < 1 en las ventanas de 5 min durante 15 min seguidos; p95 < 300 ms y errores < 0.5 %.

## 6. Evidencia a conservar
Alerta `API-DISP-RAPIDA`, traza normal contra traza del incidente (`figs/trazas_cascada.png`), gráfica de recuperación (`figs/inc01_zoom.png`), líneas `incident_opened`, `runbook_step` e `incident_resolved` del log y el run anidado `INC-2026-10-01` en MLflow.

**Resultado en la simulación (INC-2026-10-01, 12-oct):** detección en 10 min, mitigación 15 min después y MTTR de 25 min. La latencia p95 bajó de 1,580 a 120 ms y la tasa de error de 51.6 % a 0.1 %. El incidente gastó 14.7 puntos del presupuesto de disponibilidad.

## 7. Mejora posterior
- El ERP es un cliente más de la API y necesita su propio límite de consumo.
- Subir el mínimo de réplicas del HPA de 3 a 4.
