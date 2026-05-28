#!/bin/bash
set -e


/usr/sbin/sshd

echo "Uruchamiam z NODE_ID=$NODE_ID"

export PGPASSWORD='haslo'

if [ "$NODE_ID" = "1" ]; then
  if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "INIT PRIMARY"

    /usr/local/bin/docker-entrypoint.sh postgres &

    until gosu postgres pg_isready; do
      echo "Czekam na uruchomienie PostgreSQL..."
      sleep 2
    done

    gosu postgres psql -c "CREATE USER repmgr WITH REPLICATION LOGIN SUPERUSER PASSWORD 'haslo';"
    gosu postgres psql -c "CREATE DATABASE repmgr OWNER repmgr;"

    if [ -f "/config/schema.sql" ]; then
      echo "WYKRYTO PLIK SCHEMA.SQL - URUCHAMIAM IMPORT..."
      gosu postgres psql -d postgres -f /config/schema.sql
    fi


    gosu postgres repmgr -f /etc/repmgr.conf primary register

    gosu postgres pg_ctl -D "$PGDATA" -m fast stop
  fi


elif [ "$NODE_ID" = "2" ]; then
  if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "CLONE STANDBY"

    rm -rf "$PGDATA"/*

    until gosu postgres pg_isready -h wezel1; do
      echo "Czekam na Primary (wezel1)..."
      sleep 3
    done

    sleep 5

    gosu postgres repmgr \
      -h wezel1 \
      -U repmgr \
      -d repmgr \
      -f /etc/repmgr.conf \
      standby clone
  fi
fi


echo "START POSTGRES"
gosu postgres pg_ctl -D "$PGDATA" -o "-c config_file=/config/postgresql.conf" start

if [ "$NODE_ID" = "2" ]; then
  until gosu postgres pg_isready; do
    echo "Czekam na lokalny PostgreSQL na wezel2..."
    sleep 1
  done
  echo "REJESTRACJA WĘZŁA STANDBY W METADANYCH"

  gosu postgres repmgr -f /etc/repmgr.conf standby register --force
fi

echo "START REPMGRD"
exec gosu postgres repmgrd -f /etc/repmgr.conf --daemonize=false
