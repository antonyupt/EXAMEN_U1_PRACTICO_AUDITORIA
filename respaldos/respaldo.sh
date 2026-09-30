#!/bin/sh
# Tarea programada del respaldo del core · cron: 0 2 * * *
# 01/11/2025 · Jefe de Sistemas · "el respaldo tarda mucho; se excluye la tabla más pesada"
pg_dump -U postgres -d core --exclude-table=desembolsos > /respaldos/core_$(date +%F).sql
