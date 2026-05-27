# Projekt Bazy - Sklep z ubraniami

## Jak testować auto failover ?
    docker-compose up

    //zobacz stan początkowy klastra
    docker exec -it wezel1 gosu postgres repmgr cluster show

    //w osobnym terminalu włacz podgląd logów wenzl2
    docker-compose logs -f wezel2

    //symulacja awarii wenzl2
    docker-compose stop wezel1

Po okołu 60 sekundach wenzel2 zostanie wypromowany do praimary :D
