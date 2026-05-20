# Projekt Bazy - Sklep z ubraniami
Po uruchomieniu kontenerów trzeba jeszce ręcznie (zgodnie z prezentacją, jak w slajdach D–I)

## 1. SSH między węzłami (na obu):
    su - postgres

    ssh-keygen -t rsa -b 4096    # puste hasło

    ssh-copy-id postgres@030wezel2   # z węzła 1

    ssh-copy-id postgres@030wezel1   # z węzła 2

## 2. Konfiguracja pg_hba.conf i postgresql.conf (na obu węzłach):
    # pg_hba.conf — dodaj NA POCZĄTKU pliku
    local repmgr repmgr trust
    host  repmgr repmgr 0.0.0.0/0 trust
    host  replication repmgr 0.0.0.0/0 trust

    # postgresql.conf — odkomentuj/zmień
    listen_addresses = '*'
    shared_preload_libraries = 'repmgr'


## 3. Plik repmgr.conf (węzeł 1: /var/lib/postgresql/18/repmgr.conf):
    node_id = 1
    node_name = wezel1
    conninfo = 'host=030wezel1 user=repmgr password=haslo dbname=repmgr'
    data_directory = '/var/lib/postgresql/18/docker'
    service_start_command   = '/usr/lib/postgresql/18/bin/pg_ctl -D /var/lib/postgresql/18/docker start'
    service_stop_command    = '/usr/lib/postgresql/18/bin/pg_ctl -D /var/lib/postgresql/18/docker stop'
    service_restart_command = '/usr/lib/postgresql/18/bin/pg_ctl -D /var/lib/postgresql/18/docker restart'
    service_reload_command  = '/usr/lib/postgresql/18/bin/pg_ctl -D /var/lib/postgresql/18/docker reload'

    Dla węzła 2 to samo z node_id = 2, node_name = wezel2, host=030wezel2.

## 4. Podlinkuj plik (na obu, jako root):
    ln -s /var/lib/postgresql/18/repmgr.conf /etc/repmgr.conf

    Następnie restart obu kontenerów, a potem kroki G i H z prezentacji — rejestracja mastera i sklonowanie węzła 2.
