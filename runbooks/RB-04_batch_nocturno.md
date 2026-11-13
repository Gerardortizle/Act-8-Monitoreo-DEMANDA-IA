# Runbook RB-04 · Batch nocturno en riesgo o tarde

## 1. Señal que activa el runbook
- Métrica: hora de fin proyectada y hora de publicación del batch nocturno (traza `batch.nocturno`).
- Reglas: `BATCH-RIESGO` (fin proyectado después de 04:30) y `BATCH-INCUMPLIDO` (publicación al ERP después de 05:00).
- Severidad: P2 y P1.

## 2. Impacto esperado
El reabasto automático de las 05:00 corre sin pronóstico vigente (riesgo R10 de la Actividad 3).

## 3. Diagnóstico inicial
1. Revisar la traza del batch para ubicar la etapa lenta (`extract.ventas_erp`, `features.build`, `model.predict_batch`, `publish.erp`).
2. Confirmar si el problema es de datos de entrada, de cómputo o del ERP.

## 4. Acción principal
| Paso | Tipo | Acción |
|---|---|---|
| 1 | Auto | Revisar la traza del batch para ubicar la etapa lenta |
| 2 | Auto | Paralelizar la predicción por región |
| 3 | Auto | Si a las 04:50 no termina, publicar el pronóstico del día anterior desplazado con la marca "pronóstico de respaldo" |
| 4 | Auto | Avisar a compradores por Slack |
| 5 | Auto | Republicar en cuanto termine el batch completo |

Salvaguardas: el pronóstico de respaldo solo se usa un día; si se repite, se abre un P1 con el proveedor del servicio administrado (transferencia de R10).

## 5. Validación de recuperación
Publicación del pronóstico completo y conciliación de filas publicadas contra filas esperadas.

## 6. Evidencia a conservar
Traza del batch, log `batch_completed` y `reports/batch_nocturno.csv`.

**En la simulación:** el batch publicó a tiempo las 30 noches (duración entre 123 y 158 min, última publicación a las 03:38), así que este runbook no se activó. Queda documentado y conectado a sus reglas.

## 7. Mejora posterior
Simular en el piloto un retraso del ERP para probar el pronóstico de respaldo de punta a punta.
