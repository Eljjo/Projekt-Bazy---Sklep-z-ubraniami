#!/bin/bash
set -e

echo "== INIT REPMGR =="

psql -U postgres -v pwd="$POSTGRES_PASSWORD" <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'repmgr') THEN
      CREATE ROLE repmgr WITH REPLICATION LOGIN SUPERUSER PASSWORD :'pwd';
   END IF;
END
\$\$;
EOF

psql -U postgres -c "DO \$\$ BEGIN IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'repmgr') THEN CREATE DATABASE repmgr OWNER repmgr; END IF; END \$\$;"
