FROM debian:12-slim

USER root
ARG FROM_TAG
ENV DEBIAN_FRONTEND=noninteractive

ARG DEV_DEP="ca-certificates gcc g++ make build-essential git markdown pandoc"
ARG TOOLS_DEP="cron logrotate rsyslog procps curl net-tools" 
ARG BUILD_DEP="libavfilter-dev libevent-dev libpcap-dev libxmlrpc-core-c3-dev \
    libjson-glib-dev default-libmysqlclient-dev libhiredis-dev libssl-dev \
    libcurl4-openssl-dev libavcodec-extra gperf libspandsp-dev libwebsockets-dev \
    libopus-dev libiptc-dev libmnl-dev libnftnl-dev "
ARG NG_REPO="https://github.com/sipwise/rtpengine.git "

RUN apt-get update \
    && apt-get -y --quiet --force-yes upgrade curl iproute2 \
    && apt-get install -y --no-install-recommends $DEV_DEP $TOOLS_DEP $BUILD_DEP \
    && cd /usr/local/src \
    && git clone --depth=1 --branch=$FROM_TAG $NG_REPO \
    && cd /usr/local/src/rtpengine/daemon \
    && make && make install \
    && rm -Rf /usr/local/src/rtpengine \
    && apt-get purge -y --quiet --force-yes --auto-remove $DEV_DEP \
    && rm -rf /var/lib/apt/* \
    && rm -rf /var/lib/dpkg/* \
    && rm -rf /var/lib/cache/* \
    && rm -Rf /var/log/* \
    && rm -Rf /usr/local/src/* \
    && rm -Rf /var/lib/apt/lists/*

RUN mkdir -p /app
COPY /app/rtpengine-cron /etc/cron.d/rtpengine-cron
COPY /app/logrotate.conf /etc/logrotate.conf
COPY /app/rsyslog.conf /etc/rsyslog.conf
COPY /app/run.sh /app/run.sh

RUN chmod 644 /etc/cron.d/rtpengine-cron \
    && chmod 644 /etc/logrotate.conf \
    && chmod 777 /app/run.sh

ENTRYPOINT ["/app/run.sh"]
