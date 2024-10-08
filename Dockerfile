ARG BASE_IMAGE=python:3.10-alpine

FROM ${BASE_IMAGE} AS build

ENV INFLUXDB_EXPORTER_VERSION=0.11.7
ENV KEENETIC_INFLUXDB_VERSION=2.0.2

RUN apk add --no-cache git

ARG KEENETIC_INFLUXDB_VERSION
RUN git clone -b $KEENETIC_INFLUXDB_VERSION https://github.com/vitaliy-sk/keenetic-grafana-monitoring.git /tmp/keenetic-grafana-monitoring && \
  cd /tmp/keenetic-grafana-monitoring && \
  pip install --no-cache-dir --user --no-warn-script-location -r requirements.txt && \
  mkdir -p /keenetic-grafana-monitoring/config && \
  touch /keenetic-grafana-monitoring/config/config.ini && \
  chown 1000 /keenetic-grafana-monitoring/config/config.ini && \
  chmod -R a+rx /root/.local && \
  mv /tmp/keenetic-grafana-monitoring/*.py /keenetic-grafana-monitoring/ && \
  mv /tmp/keenetic-grafana-monitoring/config/metrics.json /keenetic-grafana-monitoring/config/

ARG INFLUXDB_EXPORTER_VERSION
RUN apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
        aarch64) \
            arch='arm64' ;; \
        x86) \
            arch='386' ;; \
        x86_64) \
            arch='amd64' ;; \
        armhf) \
            arch='armv6' ;; \
        armv7) \
            arch='armv7' ;; \
        *) \
            echo >&2 "error: unsupported architecture ($apkArch)"; \
            exit 1 ;; \
    esac; \
  wget https://github.com/prometheus/influxdb_exporter/releases/download/v${INFLUXDB_EXPORTER_VERSION}/influxdb_exporter-${INFLUXDB_EXPORTER_VERSION}.linux-$arch.tar.gz && \
    tar xvf influxdb_exporter-${INFLUXDB_EXPORTER_VERSION}.linux-$arch.tar.gz && \
    mv influxdb_exporter-${INFLUXDB_EXPORTER_VERSION}.linux-$arch/influxdb_exporter / && \
    rm -rf influxdb_exporter-${INFLUXDB_EXPORTER_VERSION}.linux-$arch*

FROM ${BASE_IMAGE}

RUN apk add --no-cache gettext bash && \
  adduser -D -h /app -u 1000 app

COPY config.ini.tmpl /
COPY --from=build /root/.local /app/.local
COPY --from=build /keenetic-grafana-monitoring /app/keenetic-grafana-monitoring
COPY --from=build /influxdb_exporter /app/influxdb_exporter

COPY config.ini.tmpl /
COPY start.sh /

USER app
WORKDIR /app

ENV KEENETIC_URL=http://keenetic-host:80
ENV KEENETIC_LOGIN=exporter
ENV KEENETIC_PASSWORD=secret
ENV SCRAPE_INTERVAL=20

CMD ["/start.sh"]