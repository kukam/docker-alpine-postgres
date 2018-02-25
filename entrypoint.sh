#!/bin/sh

mkdir /run/postgres
chown postgres:postgres /run/postgres
chown -R postgres "$PGDATA"

if [ -z "$(ls -A "$PGDATA")" ]; then
    gosu postgres initdb
    sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf
    { echo; echo "host all all 0.0.0.0/0 $authMethod"; } >> "$PGDATA"/pg_hba.conf
fi
    
: ${POSTGRES_ADMIN_PASS:="postgres"}
: ${POSTGRES_USER:="postgres"}
: ${POSTGRES_USER_PASS:=$POSTGRES_USER}
: ${POSTGRES_DB:=$POSTGRES_USER}

echo "ALTER USER postgres WITH PASSWORD '$POSTGRES_ADMIN_PASS';" | gosu postgres postgres --single -jE
echo   

if [ "$POSTGRES_USER" != 'postgres' ]; then
    gosu postgres createuser $POSTGRES_USER
    gosu postgres createdb $POSTGRES_DB
    echo "ALTER USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_USER_PASS';" | gosu postgres postgres --single -jE
    echo
    echo "GRANT ALL PRIVILEGES ON DATABASE '$POSTGRES_DB' TO '$POSTGRES_USER' ;
    echo
fi

exec gosu postgres "$@"
