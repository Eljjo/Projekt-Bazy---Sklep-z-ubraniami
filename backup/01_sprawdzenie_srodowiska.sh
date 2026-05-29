#!/usr/bin/env bash
set -u

PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-wezel1}"
REPLICA_CONTAINER="${REPLICA_CONTAINER:-wezel2}"
DB_NAME="${DB_NAME:-clothing_shop}"

echo "== Kontenery Docker =="
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

echo
echo "== Adresy IP kontenerow =="
for c in "${PRIMARY_CONTAINER}" "${REPLICA_CONTAINER}"; do
  printf '%s: ' "$c"
  docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$c" 2>/dev/null || echo "kontener niedostepny"
done

echo
echo "== Lista baz na ${PRIMARY_CONTAINER} =="
docker exec -u postgres "${PRIMARY_CONTAINER}" psql -l || true

echo
echo "== Schematy w bazie ${DB_NAME} =="
docker exec -u postgres "${PRIMARY_CONTAINER}" psql -d "${DB_NAME}" -c "\dn" || true

echo
echo "== Tabele shop.* =="
docker exec -u postgres "${PRIMARY_CONTAINER}" psql -d "${DB_NAME}" -c "\dt shop.*" || true

echo
echo "== Tabele admin.* =="
docker exec -u postgres "${PRIMARY_CONTAINER}" psql -d "${DB_NAME}" -c "\dt admin.*" || true

echo
echo "== Liczba rekordow w tabelach projektu =="
docker exec -i -u postgres "${PRIMARY_CONTAINER}" psql -d "${DB_NAME}" <<'SQL' || true
SELECT 'shop.stores' AS table_name, COUNT(*) AS rows_count FROM shop.stores
UNION ALL SELECT 'shop.categories', COUNT(*) FROM shop.categories
UNION ALL SELECT 'shop.products', COUNT(*) FROM shop.products
UNION ALL SELECT 'shop.product_stock', COUNT(*) FROM shop.product_stock
UNION ALL SELECT 'shop.customers', COUNT(*) FROM shop.customers
UNION ALL SELECT 'shop.orders', COUNT(*) FROM shop.orders
UNION ALL SELECT 'shop.order_items', COUNT(*) FROM shop.order_items
UNION ALL SELECT 'admin.employees', COUNT(*) FROM admin.employees
UNION ALL SELECT 'admin.audit_logs', COUNT(*) FROM admin.audit_logs
ORDER BY table_name;
SQL
