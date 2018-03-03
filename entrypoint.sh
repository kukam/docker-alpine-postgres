#!/bin/sh

mkdir /run/postgresql
chown postgres:postgres /run/postgresql
chown -R postgres "$PGDATA"

# parameters
POSTGRES_ADMIN_PWD = ${DB_ADMIN_PASSWORD:="postgres"}
POSTGRES_USER = ${DB_USER:="postgres"}
POSTGRES_USER_PWD = ${DB_USER_PASSWORD:=$POSTGRES_USER}
POSTGRES_DB = ${DB_NAME:=$POSTGRES_USER}

if [ -z "$(ls -A "$PGDATA")" ]; then

    gosu postgres initdb
    
    sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf
    
    { echo; echo "local  all  postgres    peer"; } > "$PGDATA"/pg_hba.conf
    { echo; echo "host  all  all  127.0.0.1/32  md5"; } >> "$PGDATA"/pg_hba.conf
    { echo; echo "host  all  all  ::1/128  md5"; } >> "$PGDATA"/pg_hba.conf
    { echo; echo "host  all  all  0.0.0.0/0  md5"; } >> "$PGDATA"/pg_hba.conf

    echo "ALTER USER postgres WITH PASSWORD '$POSTGRES_ADMIN_PWD';" | gosu postgres postgres --single -jE
    echo   

    if [ "$POSTGRES_USER" != 'postgres' ]; then
        echo "CREATE DATABASE $POSTGRES_DB;" | gosu postgres postgres --single -jE
        echo
        echo "CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_USER_PWD';" | gosu postgres postgres --single -jE
        echo
        echo "GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;" | gosu postgres postgres --single -jE
        echo
    fi
fi
    
exec gosu postgres "$@"
