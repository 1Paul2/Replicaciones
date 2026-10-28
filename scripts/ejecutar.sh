#!/usr/bin/env bash
# Configura y prueba la replicación bidireccional AW_A <-> AW_B.
#
#   ./scripts/ejecutar.sh configurar   pasos 0 a 4 (deja la replicación funcionando)
#   ./scripts/ejecutar.sh probar       paso 5 (insertar, modificar, eliminar)
#   ./scripts/ejecutar.sh monitorear   paso 6 (estado de los agentes)
#   ./scripts/ejecutar.sh quitar       paso 99 (elimina la replicación)
#   ./scripts/ejecutar.sh <archivo.sql>   ejecuta un script suelto
set -euo pipefail

RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
cd "$RAIZ"

[[ -f .env ]] || { echo "Falta .env (copia .env.example y pon tu clave)"; exit 1; }
# shellcheck disable=SC1091
source .env
export SQLCMDPASSWORD="$SQL_PASSWORD"

AZUL=$'\e[1;34m'; NORMAL=$'\e[0m'

sql() {  # sql <archivo.sql>
    echo "${AZUL}--- $1 ---${NORMAL}"
    sqlcmd -S "$SQL_SERVER" -U "$SQL_USER" -C -I -b -f 65001 -W -s ' | ' \
           -v SA_PASSWORD="$SQL_PASSWORD" -i "$1"
}

case "${1:-}" in
    configurar)
        sql 00_prerequisitos/01_verificar_entorno.sql
        sql 01_preparar_tablas/01_identidades_not_for_replication.sql
        sql 02_distribuidor/01_configurar_distribuidor.sql
        sql 03_publicaciones/01_publicacion_AW_A.sql
        sql 03_publicaciones/02_publicacion_AW_B.sql
        sql 04_suscripciones/01_suscripcion_AW_A_hacia_AW_B.sql
        sql 04_suscripciones/02_suscripcion_AW_B_hacia_AW_A.sql
        ;;
    probar)     for f in 05_pruebas/*.sql; do sql "$f"; done ;;
    monitorear) sql 06_monitoreo/01_estado_replicacion.sql ;;
    quitar)     sql 99_eliminar_replicacion/01_quitar_replicacion.sql ;;
    *.sql)      sql "$1" ;;
    *) sed -n '2,8p' "$0"; exit 1 ;;
esac
