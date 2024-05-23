FROM python:3.9-alpine as build

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
RUN wget https://github.com/prometheus/influxdb_exporter/releases/download/v${INFLUXDB_EXPORTER_VERSION}/influxdb_exporter-${INFLUXDB_EXPORTER_VERSION}.linux-amd64.tar.gz && \
  tar xvf influxdb_exporter-${INFLUXDB_EXPORTER_VERSION}.linux-amd64.tar.gz && \
  mv influxdb_exporter-${INFLUXDB_EXPORTER_VERSION}.linux-amd64/influxdb_exporter / && \
  rm -rf influxdb_exporter-${INFLUXDB_EXPORTER_VERSION}.linux-amd64*

FROM python:3.9-alpine

RUN apk add --no-cache gettext && \
  adduser -D -h /app -u 1000 app

COPY config.ini.tmpl /
COPY --from=build /root/.local /app/.local
COPY --from=build /keenetic-grafana-monitoring /app/keenetic-grafana-monitoring
COPY --from=build /influxdb_exporter /app/influxdb_exporter

COPY config.ini.tmpl /
COPY start.sh /

USER app
WORKDIR /app

CMD /start.sh