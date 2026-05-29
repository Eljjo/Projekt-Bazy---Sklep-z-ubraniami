#!/usr/bin/env bash
set -euo pipefail

PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-wezel1}"
DB_NAME="${DB_NAME:-clothing_shop}"
BACKUP_DIR="${BACKUP_DIR:-backups}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_FILE="${DB_NAME}_backup_${TIMESTAMP}.dump"
CONTAINER_BACKUP_PATH="/tmp/${BACKUP_FILE}"
LOCAL_BACKUP_PATH="${BACKUP_DIR}/${BACKUP_FILE}"

mkdir -p "${BACKUP_DIR}"

echo "== Sprawdzenie kontenera ${PRIMARY_CONTAINER} =="
docker inspect "${PRIMARY_CONTAINER}" >/dev/null

echo "== Sprawdzenie bazy ${DB_NAME} =="
DB_EXISTS="$(docker exec -u postgres "${PRIMARY_CONTAINER}" psql -tAc "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}';" | tr -d '[:space:]')"
if [[ "${DB_EXISTS}" != "1" ]]; then
  echo "Blad: baza ${DB_NAME} nie istnieje w kontenerze ${PRIMARY_CONTAINER}."
  exit 1
fi

echo "== Wykonanie pg_dump w formacie custom =="
docker exec -u postgres "${PRIMARY_CONTAINER}" pg_dump \
  -d "${DB_NAME}" \
  -F c \
  -f "${CONTAINER_BACKUP_PATH}"

echo "== Kopiowanie pliku backupu na hosta =="
docker cp "${PRIMARY_CONTAINER}:${CONTAINER_BACKUP_PATH}" "${LOCAL_BACKUP_PATH}"

echo "== Utworzony backup =="
ls -lh "${LOCAL_BACKUP_PATH}"
