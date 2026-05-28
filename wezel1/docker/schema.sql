-- Tworzenie bazy danych
CREATE DATABASE clothing_shop;

-- Przełączenie na bazę clothing_shop
\c clothing_shop;

-- SCHEMATY

CREATE SCHEMA IF NOT EXISTS shop;
CREATE SCHEMA IF NOT EXISTS admin;

-- TABELE W SCHEMACIE shop

-- Tabela sklepów / oddziałów
CREATE TABLE shop.stores (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address VARCHAR(150) NOT NULL
);

-- Tabela kategorii produktów
CREATE TABLE shop.categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Tabela produktów
CREATE TABLE shop.products (
    id SERIAL PRIMARY KEY,
    category_id INT NOT NULL REFERENCES shop.categories(id),
    name VARCHAR(100) NOT NULL,
    size VARCHAR(20),
    color VARCHAR(50),
    price NUMERIC(10,2) NOT NULL
);

-- Tabela stanów magazynowych produktów w sklepach
CREATE TABLE shop.product_stock (
    id SERIAL PRIMARY KEY,
    store_id INT NOT NULL REFERENCES shop.stores(id),
    product_id INT NOT NULL REFERENCES shop.products(id),
    quantity INT NOT NULL CHECK (quantity >= 0)
);

-- Tabela klientów
CREATE TABLE shop.customers (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20)
);

-- Tabela zamówień
CREATE TABLE shop.orders (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES shop.customers(id),
    store_id INT NOT NULL REFERENCES shop.stores(id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'new'
);

-- Tabela produktów w zamówieniu
CREATE TABLE shop.order_items (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES shop.orders(id),
    product_id INT NOT NULL REFERENCES shop.products(id),
    quantity INT NOT NULL CHECK (quantity > 0),
    price NUMERIC(10,2) NOT NULL
);

-- TABELE W SCHEMACIE admin

-- Tabela pracowników
CREATE TABLE admin.employees (
    id SERIAL PRIMARY KEY,
    store_id INT REFERENCES shop.stores(id),
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL
);

-- Tabela logów administracyjnych
CREATE TABLE admin.audit_logs (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES admin.employees(id),
    action TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- PRZYKŁADOWE DANE

INSERT INTO shop.stores (name, city, address) VALUES
('Sklep Centrum', 'Warszawa', 'ul. Marszałkowska 10'),
('Sklep Galeria', 'Kraków', 'ul. Floriańska 15'),
('Sklep Outlet', 'Wrocław', 'ul. Legnicka 20');

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
(2, 'Spodnie materiałowe', 'S', 'beżowy', 139.99),
(3, 'T-shirt basic', 'M', 'biały', 49.99),
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
('Katarzyna Wiśniewska', 'kasia@example.com', '502300400');

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
(1, 'Maria Zielińska', 'admin'),
(2, 'Piotr Wiśniewski', 'warehouse'),
(3, 'Olga Nowicka', 'manager');

INSERT INTO admin.audit_logs (employee_id, action) VALUES
(1, 'Utworzono bazę sklepu z ubraniami'),
(2, 'Dodano przykładowe stany magazynowe'),
(3, 'Dodano przykładowe zamówienia');

-- ROLE I UPRAWNIENIA

CREATE ROLE shop_readonly;
CREATE ROLE shop_app_user;

CREATE USER readonly_user WITH PASSWORD 'readonly123';
CREATE USER app_user WITH PASSWORD 'app123';

-- Uprawnienia dla użytkownika tylko do odczytu
GRANT USAGE ON SCHEMA shop TO shop_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA shop TO shop_readonly;

-- Uprawnienia dla użytkownika aplikacji
GRANT USAGE ON SCHEMA shop TO shop_app_user;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA shop TO shop_app_user;

-- Nadanie ról użytkownikom
GRANT shop_readonly TO readonly_user;
GRANT shop_app_user TO app_user;

-- Uprawnienia do przyszłych tabel
ALTER DEFAULT PRIVILEGES IN SCHEMA shop
GRANT SELECT ON TABLES TO shop_readonly;

ALTER DEFAULT PRIVILEGES IN SCHEMA shop
GRANT SELECT, INSERT, UPDATE ON TABLES TO shop_app_user;

-- INDEKSY

CREATE INDEX idx_products_category_id
ON shop.products(category_id);

CREATE INDEX idx_product_stock_store_id
ON shop.product_stock(store_id);

CREATE INDEX idx_product_stock_product_id
ON shop.product_stock(product_id);

CREATE INDEX idx_orders_customer_id
ON shop.orders(customer_id);

CREATE INDEX idx_orders_store_id
ON shop.orders(store_id);

CREATE INDEX idx_order_items_order_id
ON shop.order_items(order_id);

CREATE INDEX idx_order_items_product_id
ON shop.order_items(product_id);

CREATE INDEX idx_employees_store_id
ON admin.employees(store_id);
