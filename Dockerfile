FROM alpine:latest

MAINTAINER kukam "kukam@freebox.cz"

RUN apk --update --no-cache add bash postgresql postgresql-contrib \
    && mkdir /run/postgresql \
    && chmod a+rwx /run/postgresql \
    && rm -rf /var/cache/apk/*

ADD https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64 /usr/local/bin/gosu
RUN chmod +x /usr/local/bin/gosu

ENV LANG en_US.utf8
ENV PGDATA /var/lib/postgresql/data

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5432
VOLUME /var/lib/postgresql/data

ENTRYPOINT ["/entrypoint.sh"]

CMD ["postgres"]
