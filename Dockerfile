FROM alpine:latest

RUN --mount=type=cache,target=/var/cache/apk \
    --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    ln -s /var/cache/apk /etc/apk/cache && \
    apk add --update \
      mysql-client && \
    echo '' > /root/.ash_history

COPY scripts/init.sh /

CMD [ "/init.sh" ]