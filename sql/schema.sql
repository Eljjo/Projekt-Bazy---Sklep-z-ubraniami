-- Baza danych dla projektu B OUT 17: Siec sklepow z ubraniami
CREATE DATABASE clothing_shop;

\c clothing_shop;

-- Schematy
CREATE SCHEMA IF NOT EXISTS shop;
CREATE SCHEMA IF NOT EXISTS admin;

-- Tabele w schemacie shop
CREATE TABLE shop.stores (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address VARCHAR(150) NOT NULL
);

CREATE TABLE shop.categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE shop.products (
    id SERIAL PRIMARY KEY,
    category_id INT NOT NULL REFERENCES shop.categories(id),
    name VARCHAR(100) NOT NULL,
    size VARCHAR(20),
    color VARCHAR(50),
    price NUMERIC(10,2) NOT NULL CHECK (price > 0)
);

CREATE TABLE shop.product_stock (
    id SERIAL PRIMARY KEY,
    store_id INT NOT NULL REFERENCES shop.stores(id),
    product_id INT NOT NULL REFERENCES shop.products(id),
    quantity INT NOT NULL CHECK (quantity >= 0),
    UNIQUE (store_id, product_id)
);

CREATE TABLE shop.customers (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20)
);

CREATE TABLE shop.orders (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES shop.customers(id),
    store_id INT NOT NULL REFERENCES shop.stores(id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'new' CHECK (status IN ('new', 'paid', 'cancelled', 'completed'))
);

CREATE TABLE shop.order_items (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES shop.orders(id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES shop.products(id),
    quantity INT NOT NULL CHECK (quantity > 0),
    price NUMERIC(10,2) NOT NULL CHECK (price > 0)
);

-- Tabele w schemacie admin
CREATE TABLE admin.employees (
    id SERIAL PRIMARY KEY,
    store_id INT REFERENCES shop.stores(id),
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL
);

CREATE TABLE admin.audit_logs (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES admin.employees(id),
    action TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dane testowe
INSERT INTO shop.stores (name, city, address) VALUES
('Sklep Centrum', 'Warszawa', 'ul. Marszalkowska 10'),
('Sklep Galeria', 'Krakow', 'ul. Florianska 15'),
('Sklep Outlet', 'Wroclaw', 'ul. Legnicka 20');

INSERT INTO shop.categories (name) VALUES
('Bluzy'),
('Spodnie'),
('Koszulki'),
('Sukienki'),
('Kurtki');

INSERT INTO shop.products (category_id, name, size, color, price) VALUES
(1, 'Bluza oversize', 'M', 'czarny', 129.99),
(1, 'Bluza z kapturem', 'L', 'szary', 149.99),
(2, 'Jeansy damskie', 'M', 'niebieski', 159.99),
(2, 'Spodnie materialowe', 'S', 'bezowy', 139.99),
(3, 'T-shirt basic', 'M', 'bialy', 49.99),
(3, 'T-shirt z nadrukiem', 'L', 'czarny', 69.99),
(4, 'Sukienka letnia', 'S', 'czerwony', 119.99),
(5, 'Kurtka jeansowa', 'M', 'niebieski', 199.99);

INSERT INTO shop.product_stock (store_id, product_id, quantity) VALUES
(1, 1, 20),
(1, 2, 10),
(1, 3, 15),
(1, 5, 50),
(2, 1, 8),
(2, 4, 12),
(2, 6, 25),
(2, 7, 10),
(3, 3, 7),
(3, 5, 30),
(3, 8, 5);

INSERT INTO shop.customers (full_name, email, phone) VALUES
('Anna Kowalska', 'anna@example.com', '500100200'),
('Jan Nowak', 'jan@example.com', '501200300'),
('Katarzyna Wisniewska', 'kasia@example.com', '502300400');

INSERT INTO shop.orders (customer_id, store_id, status) VALUES
(1, 1, 'paid'),
(2, 2, 'new'),
(3, 3, 'paid');

INSERT INTO shop.order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 129.99),
(1, 5, 2, 49.99),
(2, 3, 1, 159.99),
(3, 8, 1, 199.99),
(3, 6, 1, 69.99);

INSERT INTO admin.employees (store_id, full_name, role) VALUES
(1, 'Maria Zielinska', 'admin'),
(2, 'Piotr Wisniewski', 'warehouse'),
(3, 'Olga Nowicka', 'manager');

INSERT INTO admin.audit_logs (employee_id, action) VALUES
(1, 'Utworzono baze sklepu z ubraniami'),
(2, 'Dodano przykladowe stany magazynowe'),
(3, 'Dodano przykladowe zamowienia');

-- Role i uprawnienia
REVOKE ALL ON SCHEMA shop FROM PUBLIC;
REVOKE ALL ON SCHEMA admin FROM PUBLIC;

CREATE ROLE shop_readonly NOLOGIN;
CREATE ROLE shop_app_user NOLOGIN;
CREATE ROLE shop_admin NOLOGIN;

CREATE USER readonly_user WITH PASSWORD 'ReadonlyPassword123!';
CREATE USER app_user WITH PASSWORD 'AppPassword123!';
CREATE USER admin_user WITH PASSWORD 'AdminPassword123!';

GRANT shop_readonly TO readonly_user;
GRANT shop_app_user TO app_user;
GRANT shop_admin TO admin_user;

GRANT CONNECT ON DATABASE clothing_shop TO shop_readonly, shop_app_user, shop_admin;

-- Uzytkownik raportowy: tylko odczyt danych biznesowych.
GRANT USAGE ON SCHEMA shop TO shop_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA shop TO shop_readonly;

-- Uzytkownik aplikacyjny: obsluga klientow i zamowien, bez dostepu do schematu admin.
GRANT USAGE ON SCHEMA shop TO shop_app_user;
GRANT SELECT ON shop.stores, shop.categories, shop.products, shop.product_stock TO shop_app_user;
GRANT SELECT, INSERT, UPDATE ON shop.customers, shop.orders, shop.order_items TO shop_app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA shop TO shop_app_user;

-- Uzytkownik administracyjny: pelny dostep do danych biznesowych i administracyjnych.
GRANT USAGE ON SCHEMA shop, admin TO shop_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA shop TO shop_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA admin TO shop_admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA shop TO shop_admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA admin TO shop_admin;

-- Uprawnienia domyslne dla przyszlych tabel i sekwencji.
ALTER DEFAULT PRIVILEGES IN SCHEMA shop
GRANT SELECT ON TABLES TO shop_readonly;

ALTER DEFAULT PRIVILEGES IN SCHEMA shop
GRANT SELECT, INSERT, UPDATE ON TABLES TO shop_app_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA shop
GRANT USAGE, SELECT ON SEQUENCES TO shop_app_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA shop
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO shop_admin;

ALTER DEFAULT PRIVILEGES IN SCHEMA admin
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO shop_admin;

ALTER DEFAULT PRIVILEGES IN SCHEMA shop
GRANT USAGE, SELECT ON SEQUENCES TO shop_admin;

ALTER DEFAULT PRIVILEGES IN SCHEMA admin
GRANT USAGE, SELECT ON SEQUENCES TO shop_admin;

-- Indeksy zwiekszajace wydajnosc typowych zapytan.
CREATE INDEX idx_products_category_id ON shop.products(category_id);
CREATE INDEX idx_product_stock_store_id ON shop.product_stock(store_id);
CREATE INDEX idx_product_stock_product_id ON shop.product_stock(product_id);
CREATE INDEX idx_orders_customer_id ON shop.orders(customer_id);
CREATE INDEX idx_orders_store_id ON shop.orders(store_id);
CREATE INDEX idx_order_items_order_id ON shop.order_items(order_id);
CREATE INDEX idx_order_items_product_id ON shop.order_items(product_id);
CREATE INDEX idx_employees_store_id ON admin.employees(store_id);
