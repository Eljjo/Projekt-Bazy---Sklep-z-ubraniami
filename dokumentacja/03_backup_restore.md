# 03. Backup i odtworzenie danych

Backup wykonywany jest z kontenera `wezel1` za pomocą `pg_dump` w formacie custom. Plik kopii zapasowej jest kopiowany na hosta lokalnego do katalogu `backups/`.

## Utworzenie backupu

```bash
./backup/02_backup_clothing_shop.sh
```

Skrypt tworzy plik w formacie:

```text
backups/clothing_shop_backup_RRRRMMDD_HHMMSS.dump
```

## Test odtworzenia

```bash
./backup/03_restore_test.sh
```

Skrypt tworzy bazę testową `clothing_shop_restore_test`, odtwarza do niej backup i uruchamia zapytania kontrolne z pliku `sql/test_restore_counts.sql`.

## Usunięcie bazy testowej

```bash
./backup/05_cleanup_restore_test.sh
```

Test odtworzenia nie nadpisuje głównej bazy `clothing_shop`.
