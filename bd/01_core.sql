-- Base de datos del core financiero · COOPAC Santa Rosa
-- Carga inicial desde la extracción entregada por la cooperativa

CREATE TABLE empleados (
    documento      varchar(8) PRIMARY KEY,
    nombre         text,
    area           text,
    fecha_ingreso  date,
    fecha_cese     date
);

CREATE TABLE usuarios (
    usuario        text PRIMARY KEY,
    documento      varchar(8),
    perfil         text,
    estado         text,
    ultimo_acceso  date
);

CREATE TABLE desembolsos (
    id                 text PRIMARY KEY,
    fecha              date,
    monto              numeric(12,2),
    usuario_registra   text,
    usuario_aprueba    text,
    umbral_aprobacion  numeric(12,2)
);

COPY empleados   FROM '/datos/empleados.csv'     WITH (FORMAT csv, HEADER true);
COPY usuarios    FROM '/datos/usuarios_core.csv' WITH (FORMAT csv, HEADER true);
COPY desembolsos FROM '/datos/desembolsos.csv'   WITH (FORMAT csv, HEADER true);

-- Cuentas de base de datos creadas por el área de TI
CREATE ROLE app_core   LOGIN SUPERUSER PASSWORD 'app_core';
CREATE ROLE reportes   LOGIN PASSWORD 'reportes2022';
CREATE ROLE ex_soporte LOGIN PASSWORD 'soporte2021';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO reportes, ex_soporte;
