#!/bin/sh

mkdir /run/postgresql
chown postgres:postgres /run/postgresql
chown -R postgres "$PGDATA"

# parameters
: ${DB_ADMIN_PASSWORD:="postgres"}
: ${DB_USER:="postgres"}
: ${DB_USER_PASSWORD:=postgres}
: ${DB_NAME:=postgres}

if [ -z "$(ls -A "$PGDATA")" ]; then

    gosu postgres initdb
    
    sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf
    
    { echo; echo "local  all  postgres    peer"; } > "$PGDATA"/pg_hba.conf
    { echo; echo "host  all  all  127.0.0.1/32  md5"; } >> "$PGDATA"/pg_hba.conf
    { echo; echo "host  all  all  ::1/128  md5"; } >> "$PGDATA"/pg_hba.conf
    { echo; echo "host  all  all  0.0.0.0/0  md5"; } >> "$PGDATA"/pg_hba.conf

    echo "ALTER USER postgres WITH PASSWORD '$DB_ADMIN_PASSWORD';" | gosu postgres postgres --single -jE
    echo   

    if [ "$DB_NAME" != 'postgres' ]; then
        echo "CREATE DATABASE $DB_NAME;" | gosu postgres postgres --single -jE
        echo
    fi

    if [ "$DB_USER" != 'postgres' ]; then
        echo "CREATE USER $DB_USER WITH PASSWORD '$DB_USER_PASSWORD';" | gosu postgres postgres --single -jE
        echo
        echo "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" | gosu postgres postgres --single -jE
        echo
    fi
fi
    
exec gosu postgres "$@"
