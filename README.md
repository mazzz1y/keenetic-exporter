# Keenetic Exporter

This repository contains a Docker setup that combines:
- [keenetic-grafana-monitoring](https://github.com/vitaliy-sk/keenetic-grafana-monitoring)
- [influxdb_exporter](https://github.com/prometheus/influxdb_exporter)

*This solution is designed for my personal use. It may not be the most elegant, but it works, and could be helpful to others in similar situations*

This setup is beneficial for those looking to use Keenetic monitoring with Prometheus instead of InfluxDB.

To build this container, run the following command:
```bash
docker build -t keenetic-exporter \
  --build-arg KEENETIC_INFLUXDB_VERSION=2.0.2 \
  --build-arg INFLUXDB_EXPORTER_VERSION=0.11.4 .
```

The following environment variables are required to start the container:
```env
KEENETIC_URL=http://keenetic-host:80
KEENETIC_LOGIN=exporter
KEENETIC_PASSWORD=secret
SCRAPE_INTERVAL=20
```

After starting, you can access the metrics endpoint at `keenetic-exporter:9122`. For example:
```bash
~ $ wget -qO- keenetic-exporter:9122/metrics | grep internet_status
# HELP internet_status_captive_accessible InfluxDB Metric
# TYPE internet_status_captive_accessible untyped
internet_status_captive_accessible 1
# HELP internet_status_dns_accessible InfluxDB Metric
# TYPE internet_status_dns_accessible untyped
internet_status_dns_accessible 1
# HELP internet_status_gateway_accessible InfluxDB Metric
# TYPE internet_status_gateway_accessible untyped
internet_status_gateway_accessible 1
# HELP internet_status_host_accessible InfluxDB Metric
# TYPE internet_status_host_accessible untyped
internet_status_host_accessible 1
# HELP internet_status_internet InfluxDB Metric
# TYPE internet_status_internet untyped
internet_status_internet 1
```