# Informe de auditoría · Core financiero de la COOPAC Santa Rosa

**SI-084 · Auditoría de Sistemas** · Examen práctico de Unidad I

| | |
|---|---|
| **Apellidos y nombres** | CHATA CHOQUE, Brant Antony |
| **Código de estudiante** | 2020067577 |
| **URL del repositorio** | `https://github.com/antonyupt/EXAMEN_U1_PRACTICO_AUDITORIA/tree/examen-u1` |
| **Fecha** | 30/09/2026 |

---

## 1. Resultados de los procedimientos

| Regla | Resultado, con cifras | ¿Cumple? | Archivo de evidencia |
|---|---|---|---|
| R1 | El contenedor `sr_bd` publica el puerto 5432 mapeado al externo `55432` enlazado en `0.0.0.0`, exponiendo la base de datos a toda la red | No | `evidencias/P1_puertos.txt` |
| R2 | La contraseña del administrador (`POSTGRES_PASSWORD`) está escrita en texto plano en `docker-compose.yml` línea 10. Tiene **10 caracteres**, inferior al mínimo de 12 exigido por la política | No | `evidencias/P2_credenciales.txt` |
| R3 | La cuenta **`app_core`** tiene el atributo `Superuser`. Además de `postgres`, existe 1 cuenta extra con privilegio de superusuario no autorizada | No | `evidencias/P3_roles.txt` |
| R4 | **16 cuentas activas** pertenecen a **10 personas cesadas** (cese más antiguo: 18/12/2015). **22 cuentas activas** no tienen documento de identidad asociado, de las cuales **4 tienen perfil `ADMIN`**: `backup`, `backup_3`, `consulta01_3`, `temporal` | No | `evidencias/P4_cesados.txt` · `evidencias/P4_genericas.txt` |
| R5 | **23 desembolsos** donde `usuario_registra = usuario_aprueba` y `monto > umbral_aprobacion`. Monto total comprometido: **S/. 709,370.47**. Usuarios distintos involucrados: **21** | No | `evidencias/P5_segregacion.txt` |
| R6 | `log_connections = off` y `log_statement = none`. El servidor **no registra** conexiones ni modificaciones de datos. Configurado explícitamente en `docker-compose.yml` línea 11 | No | `evidencias/P6_registro.txt` |
| R7 | Último respaldo exitoso: **14/11/2025** (47 días antes del corte 31/12/2025). La tabla `desembolsos` fue **excluida deliberadamente** del respaldo (`--exclude-table=desembolsos`). Respaldos del 27 al 31/12/2025 fallaron por `No space left on device`. Restauración: solo **2 tablas** recuperadas (`empleados`, `usuarios`); falta `desembolsos` | No | `evidencias/P7_respaldos.txt` · `evidencias/P7_restauracion.txt` |

---

## 2. Hallazgo 1 — Segregación de funciones vulnerada en desembolsos

| Elemento | Contenido |
|---|---|
| **Título** | Un mismo usuario registra y aprueba desembolsos que superan el umbral de aprobación |
| **Condición** | Se identificaron **23 desembolsos** en los que `usuario_registra = usuario_aprueba` y el monto supera el umbral de aprobación. El monto total comprometido asciende a **S/. 709,370.47**, ejecutados por **21 usuarios distintos**. El desembolso de mayor cuantía corresponde al usuario `u001` por **S/. 161,160.52** (ID `D00680`, fecha 17/08/2025). Evidencia: `evidencias/P5_segregacion.txt` |
| **Criterio** | **R5** de la Política de Seguridad v2.0 (aprobada 15/03/2024): *"Un desembolso que supera el umbral de aprobación no puede aprobarlo quien lo registró."* Control de referencia: **A.5.3 Segregación de funciones** — NTP-ISO/IEC 27001:2022 |
| **Causa** | El sistema de gestión de desembolsos no implementa ninguna validación a nivel de base de datos ni de aplicación que impida que el mismo usuario ocupe simultáneamente el rol de registrador y aprobador. La lógica de control de cuatro ojos (*maker-checker*) no está programada, permitiendo que cualquier usuario con ambos permisos evite el control sin restricción técnica |
| **Efecto** | La cooperativa está expuesta a fraude interno: un empleado puede autorizar desembolsos a su propio favor sin supervisión. Los **S/. 709,370.47** ya desembolsados carecen de segunda firma válida, lo que podría implicar pérdida directa de fondos de los socios y sanciones regulatorias de la SBS por incumplimiento de controles internos |
| **Recomendación** | El **Jefe de Sistemas** debe implementar en un plazo no mayor a **15 días hábiles** un `TRIGGER` o `CHECK CONSTRAINT` en la tabla `desembolsos` que rechace cualquier registro donde `usuario_registra = usuario_aprueba` cuando el monto supere el umbral. Paralelamente, el área de **Riesgos** debe revisar los 23 desembolsos identificados para determinar si existe perjuicio económico y escalar al Consejo de Administración |

---

## 3. Hallazgo 2 — Respaldo sin tabla de desembolsos y fallo del proceso al cierre 2025

| Elemento | Contenido |
|---|---|
| **Título** | La tabla `desembolsos` fue excluida deliberadamente del respaldo y el proceso falló los últimos 5 días del ejercicio 2025 |
| **Condición** | El último respaldo exitoso data del **14/11/2025**, 47 días antes del corte (31/12/2025). El script `respaldo.sh` excluye explícitamente la tabla `desembolsos` mediante el flag `--exclude-table=desembolsos`. Entre el **27 y el 31/12/2025** el proceso falló con `No space left on device`, por lo que no existe ningún respaldo del cierre del ejercicio. La restauración de `core_2025-11-14.sql` solo recupera **2 tablas** (`empleados`, `usuarios`); la tabla `desembolsos` no está presente. Evidencia: `evidencias/P7_respaldos.txt` · `evidencias/P7_restauracion.txt` |
| **Criterio** | **R7** de la Política de Seguridad v2.0: *"Respaldo diario completo, que incluye la tabla de desembolsos. Su restauración se prueba cada trimestre."* Control de referencia: **A.8.13 Respaldo de la información** — NTP-ISO/IEC 27001:2022 |
| **Causa** | El **Jefe de Sistemas** modificó el script `respaldo.sh` el 01/11/2025 excluyendo la tabla `desembolsos` para reducir el tiempo de ejecución, sin evaluar el impacto en la política ni obtener autorización del Consejo de Administración. Adicionalmente, el disco de respaldo no fue monitoreado y se llenó el 27/12/2025, deteniendo el proceso durante los días de mayor movimiento del cierre anual |
| **Efecto** | Ante un fallo de base de datos, la cooperativa no puede recuperar el historial de desembolsos del ejercicio 2025. Esto implica: (1) pérdida irreversible de información de créditos otorgados; (2) imposibilidad de auditar las operaciones del período; (3) incumplimiento regulatorio ante la SBS, que exige disponibilidad de información crediticia; (4) los 5 días sin respaldo representan el período de mayor riesgo de pérdida de datos del año |
| **Recomendación** | **Plazo inmediato (48 h):** el Jefe de Sistemas debe restaurar el script original incluyendo la tabla `desembolsos` y ampliar la capacidad del disco de respaldo. **Plazo de 30 días:** implementar monitoreo automático del espacio en disco con alertas al 80 % de uso y realizar una prueba de restauración completa documentada. El **Consejo de Administración** debe ser informado de que no existe respaldo de desembolsos del ejercicio 2025 y evaluar medidas de recuperación alternativas |