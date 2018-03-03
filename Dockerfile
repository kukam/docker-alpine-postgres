FROM alpine:latest

MAINTAINER kukam "kukam@freebox.cz"

RUN apk --update --no-cache add bash postgresql postgresql-contrib \
    && rm -rf /var/cache/apk/*

ADD https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64 /usr/local/bin/gosu
RUN chmod +x /usr/local/bin/gosu

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV DBPORT 7775
ENV LANG en_US.utf8
ENV PGDATA /dbhome

EXPOSE ${DBPORT}
VOLUME ${PGDATA}

ENTRYPOINT ["/entrypoint.sh"]

CMD ["postgres", "-p", "7775"]
