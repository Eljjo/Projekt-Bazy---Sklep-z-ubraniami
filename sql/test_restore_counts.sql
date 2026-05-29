-- Testy SQL po odtworzeniu backupu do bazy clothing_shop_restore_test.

SELECT current_database();

SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('shop', 'admin')
ORDER BY schema_name;

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema IN ('shop', 'admin')
ORDER BY table_schema, table_name;

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
