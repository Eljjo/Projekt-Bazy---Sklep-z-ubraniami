# 04. Komendy i wyniki do dokumentacji

## Uruchomienie środowiska

```bash
cp .env.example .env
docker compose up --build
```

## Sprawdzenie kontenerów i tabel

```bash
./backup/01_sprawdzenie_srodowiska.sh
```

## Sprawdzenie replikacji

```bash
./backup/04_sprawdzenie_replikacji.sh
```

## Wykonanie backupu

```bash
./backup/02_backup_clothing_shop.sh
```

## Odtworzenie backupu do bazy testowej

```bash
./backup/03_restore_test.sh
```

## Symulacja awarii primary

```bash
docker compose stop wezel1
docker exec -it wezel2 gosu postgres repmgr -f /etc/repmgr.conf cluster show
```

Po zatrzymaniu `wezel1` usługa `repmgrd` na `wezel2` przeprowadza promocję repliki do roli primary.
