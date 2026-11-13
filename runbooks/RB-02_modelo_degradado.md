# Runbook RB-02 · Modelo degradado después de un despliegue

## 1. Señal que activa el runbook
- Métrica: WMAPE y sesgo diarios (con las ventas reales del día anterior, a las 06:00).
- Reglas: `MODELO-POST-DESPLIEGUE` (versión con menos de 72 h, WMAPE > 32 % y más de 5 puntos sobre su línea base de 7 días) o `MODELO-DEGRADADO` (WMAPE > 38 % o |sesgo| > 20 %) con una versión de menos de 7 días.
- Severidad: P1.

## 2. Impacto esperado
El reabasto de las 140 sucursales se genera con un pronóstico peor: faltantes, sobreinventario y merma (beneficios B01 a B03).

## 3. Diagnóstico inicial
1. Verificar la antigüedad del champion.
2. Recalcular el mismo día con la versión `previous` en modo sombra.
3. Confirmar que la versión anterior es mejor antes de revertir.

## 4. Acción principal
| Paso | Tipo | Acción |
|---|---|---|
| 1 | Auto | Verificar la antigüedad del champion |
| 2 | Auto | Recalcular el día con la versión `previous` en modo sombra |
| 3 | Auto | Revisar la salvaguarda de un rollback automático por cada 24 h |
| 4 | Auto | Mover el alias `champion` a la versión `previous` en el Model Registry |
| 5 | Auto | Re-ejecutar el batch del día y republicar al ERP antes del corte de compras de las 10:00 |
| 6 | Auto | Congelar reentrenamientos programados y abrir postmortem |
| 7 | Auto | Al día siguiente, verificar el WMAPE del día republicado |

Escalamiento: si la versión `previous` también falla en el paso 2, no hay rollback automático; decide el Científico de datos.

## 5. Validación de recuperación
WMAPE del día republicado ≤ 32 % (dentro del SLO de calidad).

## 6. Evidencia a conservar
Model Registry con la versión retirada etiquetada `estado=rechazado-rollback` y el ID del incidente, alias `champion` y `previous` actualizados, gráfica de WMAPE por versión (`figs/modelo_wmape.png`), líneas del log y run anidado `INC-2026-10-02`.

**Resultado en la simulación (INC-2026-10-02, 17-18 oct):** v3 llegó a producción con la columna `promo` en ceros y dio 34.4 % de WMAPE contra 22.6 % de v2. El rollback y la republicación tomaron 31 min desde la alerta. Solo un día quedó fuera de SLO. El MTTD fue de 29 h porque las ventas reales llegan al día siguiente.

## 7. Mejora posterior
- Compuerta relativa: el challenger no puede ser más de 1 punto peor que el champion.
- Compuertas por segmento (promoción, categoría respiratoria, sucursales pequeñas).
- Validación de esquema: rechazar el entrenamiento si una variable clave sale constante.
- Modo sombra de una semana antes de promover un reentrenamiento programado.
