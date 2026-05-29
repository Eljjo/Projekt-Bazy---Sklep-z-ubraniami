# 01. Założenia aplikacji

Projekt dotyczy krytycznej aplikacji dla sieci sklepów z ubraniami. System obsługuje sprzedaż, produkty, stany magazynowe, klientów, zamówienia, pracowników oraz logi administracyjne.

## Baza danych

- nazwa bazy: `clothing_shop`,
- schemat `shop`: dane biznesowe sklepu,
- schemat `admin`: dane pracowników i logi administracyjne.

## Uzasadnienie krytyczności

Awaria bazy danych blokuje obsługę sprzedaży, sprawdzanie dostępności produktów, realizację zamówień oraz dostęp do danych klientów. Z tego powodu projekt wykorzystuje replikację PostgreSQL, mechanizmy backup/restore oraz rozdzielenie uprawnień użytkowników.

## Role użytkowników

- `shop_readonly` / `readonly_user`: wyłącznie odczyt danych ze schematu `shop`,
- `shop_app_user` / `app_user`: obsługa klientów i zamówień w schemacie `shop`, bez dostępu do schematu `admin`,
- `shop_admin` / `admin_user`: pełny dostęp do schematów `shop` i `admin`.
