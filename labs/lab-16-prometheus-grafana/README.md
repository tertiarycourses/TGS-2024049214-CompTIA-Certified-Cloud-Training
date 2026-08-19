# Lab 16 — Observability with Prometheus & Grafana

In this lab you will scrape a node's metrics with **Prometheus**, visualise them in **Grafana**, and trigger an **alert** when CPU rises — covering the exam's logging/monitoring/alerting/triage sub-objectives.

## Lab platform

Run all commands on the **Killercoda Ubuntu Playground**:

https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Install Docker

```bash
apt update && apt install -y docker.io stress-ng curl
systemctl start docker
```

---

## Step 2 — Run node-exporter (metrics source)

```bash
docker run -d --name node --net=host \
  prom/node-exporter:latest
sleep 2
curl -s http://localhost:9100/metrics | head -5
> Ready-made file: [`prom.yml`](prom.yml) — you can download it instead of typing this block.

```

---

## Step 3 — Configure and run Prometheus

> Ready-made file: [`alerts.yml`](alerts.yml) — you can download it instead of typing this block.

```bash
mkdir -p /tmp/prom && cat > /tmp/prom/prom.yml <<'EOF'
global:
  scrape_interval: 5s
scrape_configs:
  - job_name: node
    static_configs:
      - targets: ['localhost:9100']
rule_files: ['alerts.yml']
EOF

cat > /tmp/prom/alerts.yml <<'EOF'
groups:
- name: cpu
  rules:
  - alert: HighCPU
    expr: 1 - avg(rate(node_cpu_seconds_total{mode="idle"}[1m])) > 0.5
    for: 30s
    labels: { severity: warning }
    annotations: { summary: "CPU > 50%" }
EOF

docker run -d --name prom --net=host \
  -v /tmp/prom:/etc/prometheus \
  prom/prometheus --config.file=/etc/prometheus/prom.yml
sleep 5
curl -s 'http://localhost:9090/api/v1/query?query=up' | head -c 200
```

---

## Step 4 — Run Grafana

```bash
docker run -d --name grafana --net=host \
  -e GF_SECURITY_ADMIN_PASSWORD=cloud \
  grafana/grafana:latest
sleep 6
curl -s -u admin:cloud http://localhost:3000/api/health
```

Add the Prometheus data source via API:

```bash
curl -s -u admin:cloud -H 'Content-Type: application/json' \
  -d '{"name":"prom","type":"prometheus","url":"http://localhost:9090","access":"proxy","isDefault":true}' \
  http://localhost:3000/api/datasources
```

Open `http://<killercoda-host>:3000` in the playground's "Traffic / Ports" tab and explore.

---

## Step 5 — Trigger the alert

```bash
stress-ng --cpu 4 --timeout 60s &
sleep 45
curl -s 'http://localhost:9090/api/v1/alerts' | head -c 400
```

Within ~30s the `HighCPU` alert is **firing** — Prometheus does the triage; alertmanager (production) does the response (PagerDuty, Slack, Teams).

---

## Step 6 — Three pillars summary

| Pillar | Tool you used | Lab |
|--------|--------------|-----|
| Metrics | Prometheus + node-exporter | 16 |
| Logs | rsyslog / ELK | 17 |
| Traces | Jaeger | 18 |

Together they make a system **observable** — you can ask new questions about it without re-deploying.

---

## Step 7 — Cleanup

```bash
docker rm -f node prom grafana
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
curl -s http://localhost:9100/metrics | head -5
curl -s 'http://localhost:9090/api/v1/targets' | jq '.data.activeTargets[].health'
curl -s 'http://localhost:9090/api/v1/query?query=up' | jq '.data.result[].value[1]'
curl -s -u admin:cloud http://localhost:3000/api/health
curl -s 'http://localhost:9090/api/v1/alerts' | jq '.data.alerts[].state'
```

**Expected:** Run this before Step 7. node-exporter returns Prometheus text metrics (`# HELP ...` lines); the Prometheus target health is `"up"` and the `up` query returns `"1"`; Grafana's health endpoint returns `"database": "ok"`; and while `stress-ng` is loading the CPU the alerts endpoint shows the `HighCPU` alert in state `"pending"` and then `"firing"` after ~30 seconds.

---

## What you learned
- Scrape metrics, visualise, and alert on thresholds.
- Aggregation and retention are configured in Prometheus.
- Alerting → triage → response is the operational loop.

## Free tools used
- Prometheus — https://prometheus.io
- Grafana OSS — https://grafana.com/oss/grafana
- node-exporter — https://github.com/prometheus/node_exporter
- stress-ng — https://github.com/ColinIanKing/stress-ng

---

## Files in this lab

| File | Purpose |
|------|---------|
| [`prom.yml`](prom.yml) | Step 3 Prometheus config — scrapes node-exporter every 5s and loads the alert rules. |
| [`alerts.yml`](alerts.yml) | Step 3 alert rules — the `HighCPU` rule that fires above 50% CPU. |
