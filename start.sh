#!/bin/sh

set -e

envsubst < /config.ini.tmpl > /app/keenetic-grafana-monitoring/config/config.ini

/app/influxdb_exporter &
python3 -u /app/keenetic-grafana-monitoring/keentic_influxdb_exporter.py
