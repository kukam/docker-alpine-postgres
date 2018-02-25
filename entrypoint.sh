#!/bin/sh

mkdir /run/postgresql
chown postgres:postgres /run/postgresql
chown -R postgres "$PGDATA"

if [ -z "$(ls -A "$PGDATA")" ]; then

    gosu postgres initdb
    
    sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf
    
    { echo; echo "host all all 0.0.0.0/0 md5"; } >> "$PGDATA"/pg_hba.conf

    : ${POSTGRES_ADMIN_PASS:="postgres"}
    : ${POSTGRES_USER:="postgres"}
    : ${POSTGRES_USER_PASS:=$POSTGRES_USER}
    : ${POSTGRES_DB:=$POSTGRES_USER}

    echo "ALTER USER postgres WITH PASSWORD '$POSTGRES_ADMIN_PASS';" | gosu postgres postgres --single -jE
    echo   

    if [ "$POSTGRES_USER" != 'postgres' ]; then
        echo "CREATE DATABASE $POSTGRES_DB;" | gosu postgres postgres --single -jE
        echo
        echo "CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_USER_PASS';" | gosu postgres postgres --single -jE
        echo
        echo "GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;" | gosu postgres postgres --single -jE
        echo
    fi
fi
    
exec gosu postgres "$@"
