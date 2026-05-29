# 02. Architektura rozwiązania

## Hosty i adresy IP

| Host | Adres IP | Rola | Opis |
|---|---:|---|---|
| `wezel1` | `172.30.0.11` | PostgreSQL primary | Główna baza `clothing_shop`, zapis i odczyt |
| `wezel2` | `172.30.0.12` | PostgreSQL standby/replica | Replika w trybie hot standby, odczyt i przejęcie roli primary po awarii |
| host lokalny | - | backup storage | Pliki `clothing_shop_backup_*.dump` utworzone przez `pg_dump` |

## Sieć

Kontenery działają w sieci Docker `repmgrnet` z podsiecią `172.30.0.0/24`. Połączenia sieciowe do PostgreSQL są ograniczone w plikach `pg_hba.conf` do tej podsieci.

## Baza danych

- baza: `clothing_shop`,
- schematy: `shop`, `admin`,
- narzędzie replikacji: `repmgr`,
- tryb repliki: `hot_standby = on`.

## Diagram

Plik diagramu znajduje się w katalogu `diagram/`:

- `architektura_sklep_ubrania.png`,
- `architektura_sklep_ubrania.svg`,
- `architektura_sklep_ubrania.drawio`,
- `architektura_sklep_ubrania.mmd`.
