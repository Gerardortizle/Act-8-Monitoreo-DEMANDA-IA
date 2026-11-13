# Relación con la rúbrica y los entregables de la Actividad 8

## Entregables

| Entregable solicitado | Dónde está |
|---|---|
| 1. Documento técnico | `docs/01_documento_tecnico.pdf` |
| 2. Evidencia de implementación | `docs/02_evidencia_implementacion.pdf` (capturas de MLflow, tableros y alertas) |
| 3. Simulación de incidentes | `docs/03_simulacion_incidentes.pdf` |
| 4. Código y configuración de alertas | `src/`, `notebooks/` y `config/` |

## Criterios de la rúbrica

| Criterio | Evidencia en el repositorio |
|---|---|
| 1. Diseño de monitorización y observabilidad | Métricas registradas en MLflow (API, calidad, drift y batch); logs JSON (`logs/demanda_ia.jsonl`); trazas OpenTelemetry (`traces/spans.jsonl`); vínculo de cada indicador con los beneficios y riesgos de la Actividad 3 (sección 2 del documento técnico) |
| 2. Diseño y aplicación de alertas inteligentes | `config/slo_alertas.yaml` con 4 SLO, presupuestos de error y 11 reglas P1 a P3; burn rate con dos ventanas; deduplicación, inhibición y vinculación a incidentes. Resultado: 4 notificaciones contra 193 con reglas de umbral fijo (97.9 % menos ruido) |
| 3. Simulación de incidentes y uso de runbooks | Tres incidentes inyectados en el código (API saturada, modelo v3 defectuoso y drift por frente frío); `runbooks/RB-01` a `RB-04`; bitácora de cada incidente en el log y como run anidado en MLflow |
| 4. Documentación de la respuesta automatizada | Clase `Responder` del script: escalamiento, rate limiting, rollback por alias, republicación, corrección de sesgo, reentrenamiento con compuertas y canary; 29 de 32 pasos automáticos, con salvaguardas y aprobación humana en los dos pasos de mayor riesgo |

## Cadena que se pidió demostrar

```text
indicador → SLO → alerta → incidente → runbook → respuesta → evidencia de recuperación
```

| Incidente | Indicador | SLO | Alerta | Runbook | Respuesta | Recuperación |
|---|---|---|---|---|---|---|
| INC-2026-10-01 | Burn rate de disponibilidad | SLO-API-DISP | API-DISP-RAPIDA (P1) | RB-01 | 8 réplicas, rate limiting, caché | p95 1,580 → 120 ms; MTTR 25 min |
| INC-2026-10-02 | WMAPE diario | SLO-CALIDAD | MODELO-POST-DESPLIEGUE (P1) | RB-02 | Rollback de v3 a v2 | WMAPE 34.4 % → 26.1 %; 1 día fuera de SLO |
| INC-2026-10-03 | Anomalía de temperatura y PSI | SLO-CALIDAD | DRIFT-DATOS (P2 → P1) | RB-03 | Corrección, reentrenamiento v4, canary | 2 días fuera de SLO contra 5 sin respuesta |
