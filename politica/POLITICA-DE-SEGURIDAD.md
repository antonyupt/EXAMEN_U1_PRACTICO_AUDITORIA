# Política de seguridad del core financiero

**COOPAC Santa Rosa** · Versión 2.0 · Aprobada por el Consejo de Administración el 15/03/2024

| Regla | Lo que la cooperativa se obliga a cumplir | Control de referencia · NTP-ISO/IEC 27001:2022 |
|---|---|---|
| **R1** | La base de datos solo acepta conexiones desde el propio servidor. No se publica a la red | A.8.20 Seguridad de redes |
| **R2** | Ninguna contraseña se escribe en texto plano en archivos de configuración. Toda contraseña tiene 12 caracteres o más | A.5.17 Información de autenticación |
| **R3** | Ninguna cuenta, salvo la del administrador `postgres`, tiene privilegio de superusuario | A.8.2 Derechos de acceso privilegiado |
| **R4** | La cuenta de una persona se desactiva el día de su cese. No existen cuentas activas sin persona responsable | A.5.16 Gestión de identidades · A.5.18 Derechos de acceso |
| **R5** | Un desembolso que supera el umbral de aprobación no puede aprobarlo quien lo registró | A.5.3 Segregación de funciones |
| **R6** | La base de datos registra todas las conexiones y todas las modificaciones de datos | A.8.15 Registro de eventos |
| **R7** | Respaldo diario completo, que incluye la tabla de desembolsos. Su restauración se prueba cada trimestre | A.8.13 Respaldo de la información |

**Responsable de su cumplimiento.** Jefe de Sistemas.
