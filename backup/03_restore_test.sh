#!/usr/bin/env bash
set -euo pipefail

PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-wezel1}"
SOURCE_DB_NAME="${SOURCE_DB_NAME:-clothing_shop}"
RESTORE_DB_NAME="${RESTORE_DB_NAME:-clothing_shop_restore_test}"
BACKUP_DIR="${BACKUP_DIR:-backups}"

if [[ $# -ge 1 ]]; then
  LOCAL_BACKUP_PATH="$1"
else
  LOCAL_BACKUP_PATH="$(ls -1t "${BACKUP_DIR}/${SOURCE_DB_NAME}_backup_"*.dump 2>/dev/null | head -n 1 || true)"
fi

if [[ -z "${LOCAL_BACKUP_PATH}" || ! -f "${LOCAL_BACKUP_PATH}" ]]; then
  echo "Blad: nie znaleziono pliku backupu."
  echo "Uruchom backup albo podaj sciezke do pliku .dump."
  exit 1
fi

BACKUP_BASENAME="$(basename "${LOCAL_BACKUP_PATH}")"
CONTAINER_BACKUP_PATH="/tmp/${BACKUP_BASENAME}"

echo "== Plik backupu =="
ls -lh "${LOCAL_BACKUP_PATH}"

echo "== Kopiowanie backupu do kontenera ${PRIMARY_CONTAINER} =="
docker cp "${LOCAL_BACKUP_PATH}" "${PRIMARY_CONTAINER}:${CONTAINER_BACKUP_PATH}"

echo "== Przygotowanie bazy testowej ${RESTORE_DB_NAME} =="
docker exec -u postgres "${PRIMARY_CONTAINER}" dropdb --if-exists "${RESTORE_DB_NAME}"
docker exec -u postgres "${PRIMARY_CONTAINER}" createdb "${RESTORE_DB_NAME}"

echo "== Odtworzenie backupu do bazy testowej =="
docker exec -u postgres "${PRIMARY_CONTAINER}" pg_restore \
  -d "${RESTORE_DB_NAME}" \
  "${CONTAINER_BACKUP_PATH}"

echo "== Weryfikacja odtworzonych danych =="
docker exec -i -u postgres "${PRIMARY_CONTAINER}" psql -d "${RESTORE_DB_NAME}" < sql/test_restore_counts.sql

echo
echo "Test odtworzenia zakonczony poprawnie. Baza testowa: ${RESTORE_DB_NAME}"
