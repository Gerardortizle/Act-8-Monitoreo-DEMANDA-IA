# Runbook RB-03 · Data drift o modelo en riesgo

## 1. Señal que activa el runbook
- Métricas: PSI por variable clave (ventana de 7 días), anomalía de temperatura contra la climatología, % de sucursales fuera del rango p1-p99, WMAPE y sesgo por categoría.
- Reglas: `DRIFT-DATOS` (≥ 30 % de variables con PSI > 0.2, PSI de promo > 0.25 o > 20 % de sucursales con temperatura fuera de rango) o `MODELO-EN-RIESGO` (WMAPE > 32 % con presupuesto de calidad < 50 %).
- Severidad: P2; escala a P1 si se vincula `MODELO-DEGRADADO`.

## 2. Impacto esperado
El modelo deja de representar la demanda. Suele afectar primero a una categoría (respiratorio en temporada de frío). Es el riesgo R08, el de mayor EMV en la Actividad 3.

## 3. Diagnóstico inicial
1. Identificar qué variables y qué categorías cambiaron.
2. Confirmar que el cambio es real (no un problema de carga de datos).
3. Revisar si la versión `previous` conoce el nuevo régimen; si no, el rollback no sirve.

## 4. Acción principal
| Paso | Tipo | Acción |
|---|---|---|
| 1 | Auto | Identificar variables y categorías afectadas |
| 2 | Auto | Publicar con bandera de drift en el ERP |
| 3 | Auto | Corrección temporal de sesgo por categoría (factor acotado entre 0.6 y 1.9) y republicación |
| 4 | Auto | Actualizar los factores cada mañana con el error del día previo |
| 5 | Auto | Reentrenar cuando haya al menos 3 días del nuevo régimen |
| 6 | Auto | Compuertas fuera de muestra: no peor que el champion corregido, al menos 2 puntos mejor que el champion sin corregir y sesgo ≤ 15 % |
| 7 | Semi | Canary en 20 % de las sucursales durante una noche |
| 8 | Semi | Promover a champion, retirar la corrección y mover la referencia de drift |
| 9 | Auto | Verificar el primer día completo con la versión nueva |

Escalamiento: si las compuertas fallan dos veces seguidas, el Científico de datos revisa variables y ventana de entrenamiento.

Salvaguardas: la corrección solo aplica a las filas del champion, nunca a las del canary, y no debe bajar el pronóstico de medicamentos esenciales por debajo de su piso de abasto (riesgo R04).

## 5. Validación de recuperación
WMAPE ≤ 32 % en el primer día completo con la versión nueva y PSI de vigilancia estable.

## 6. Evidencia a conservar
Mapa de PSI (`figs/psi_heatmap.png`), WMAPE por versión, corrida de reentrenamiento `train-v4` con sus compuertas, alias `challenger` y `champion`, líneas del log y run anidado `INC-2026-10-03`.

**Resultado en la simulación (INC-2026-10-03, 22-28 oct):** el frente frío se detectó la misma noche (03:18, antes de publicar) con 100 % de sucursales fuera de rango. La corrección contuvo el error mientras se reentrenaba v4; el canary dio 23.4 % contra 34.3 % y v4 quedó como champion el 27. Hubo 2 días fuera de SLO, contra 5 sin respuesta (≈ 86 mil MXN de beneficio en riesgo contra ≈ 216 mil).

## 7. Mejora posterior
- La corrección por factor solo compra tiempo; cuando la temperatura bajó todavía más el 25 se quedó corta.
- Complementar el SLO mensual de calidad con un tope anual de 5 días fuera de SLO, alineado con el riesgo residual de R08.
