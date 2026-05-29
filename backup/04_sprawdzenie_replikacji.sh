#!/usr/bin/env bash
set -u

PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-wezel1}"
REPLICA_CONTAINER="${REPLICA_CONTAINER:-wezel2}"
DB_NAME="${DB_NAME:-clothing_shop}"

echo "== Status klastra repmgr z ${PRIMARY_CONTAINER} =="
docker exec -u postgres "${PRIMARY_CONTAINER}" repmgr -f /etc/repmgr.conf cluster show || true

echo
echo "== Status klastra repmgr z ${REPLICA_CONTAINER} =="
docker exec -u postgres "${REPLICA_CONTAINER}" repmgr -f /etc/repmgr.conf cluster show || true

echo
echo "== Replikacja widziana z wezla primary =="
docker exec -u postgres "${PRIMARY_CONTAINER}" psql -c "SELECT client_addr, state, sync_state FROM pg_stat_replication;" || true

echo
echo "== Czy ${REPLICA_CONTAINER} jest w trybie standby? =="
docker exec -u postgres "${REPLICA_CONTAINER}" psql -c "SELECT pg_is_in_recovery();" || true

echo
echo "== Test odczytu danych z repliki =="
docker exec -u postgres "${REPLICA_CONTAINER}" psql -d "${DB_NAME}" -c "SELECT COUNT(*) AS products_count FROM shop.products;" || true
