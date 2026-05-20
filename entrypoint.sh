#!/bin/bash
set -e

/usr/sbin/sshd

/usr/local/bin/docker-entrypoint.sh "$@"

while true; do
    sleep 60
done
