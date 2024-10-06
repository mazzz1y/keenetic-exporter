# Keenetic Exporter

This repository contains a Docker setup that combines:
- [keenetic-grafana-monitoring](https://github.com/vitaliy-sk/keenetic-grafana-monitoring)
- [influxdb_exporter](https://github.com/prometheus/influxdb_exporter)

*This solution is designed for my personal use. It may not be the most elegant, but it works, and could be helpful to others in similar situations*

This setup is beneficial for those looking to use Keenetic monitoring with Prometheus instead of InfluxDB.

## Start

To run this container, run the following command:

```bash
docker run -d \
  -p "127.0.0.1:9122:9122"
  -e KEENETIC_URL=http://192.168.1.1:80 \
  -e KEENETIC_LOGIN=monitoring \
  -e KEENETIC_PASSWORD=password \
  -e SCRAPE_INTERVAL=20 \
  ghcr.io/mazzz1y/keenetic-exporter:latest
```

After starting, you can check the metrics endpoint at `127.0.0.1:9122`:
```bash
~ $ wget -qO- 127.0.0.1:9122/metrics | grep internet_status
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

If everything works, let's add it to Prometheus:
```yaml
  - job_name: 'keenetic-exporter'
    static_configs:
      - targets: ['127.0.0.1:9122']
    metric_relabel_configs:
    - source_labels: [__name__]
      target_label: __name__
      replacement: keenetic_$1
```

### Versioning
```
${KEENETIC_INFLUXDB_VERSION}-${INFLUXDB_EXPORTER_VERSION}-${BUILD_VERSION}
```