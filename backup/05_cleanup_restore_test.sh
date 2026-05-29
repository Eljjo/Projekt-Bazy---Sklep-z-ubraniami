#!/usr/bin/env bash
set -euo pipefail

PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-wezel1}"
RESTORE_DB_NAME="${RESTORE_DB_NAME:-clothing_shop_restore_test}"

echo "== Usuniecie testowej bazy ${RESTORE_DB_NAME} =="
docker exec -u postgres "${PRIMARY_CONTAINER}" dropdb --if-exists "${RESTORE_DB_NAME}"

echo "Gotowe."
