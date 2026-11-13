# runbooks/

Cada runbook sigue la estructura de la plantilla del starter (señal, impacto, diagnóstico, acción, validación, evidencia y mejora) y marca cada paso como automático, semiautomático o manual. Los mismos pasos están implementados como código en la clase `Responder` de `src/Act__8__Monitoreo_DEMANDA-IA_JGOL.py`, así que lo que dice el runbook y lo que se ejecuta no se separan.

| Runbook | Incidente que lo activa | ¿Se probó en la simulación? |
|---|---|---|
| [RB-01](RB-01_saturacion_api.md) | Saturación o caída de forecast-api | Sí: INC-2026-10-01 |
| [RB-02](RB-02_modelo_degradado.md) | Modelo degradado después de un despliegue | Sí: INC-2026-10-02 |
| [RB-03](RB-03_data_drift.md) | Data drift o modelo en riesgo | Sí: INC-2026-10-03 |
| [RB-04](RB-04_batch_nocturno.md) | Batch nocturno en riesgo o tarde | No: el batch publicó a tiempo las 30 noches; queda documentado |
