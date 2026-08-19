# Lab 17 — Centralized Logging with the ELK Stack

In this lab you will run **Elasticsearch**, **Logstash**, and **Kibana** (ELK) on the Killercoda VM, ship logs from `rsyslog`, and query them through Kibana's API.

> ELK images are heavy (~1.5 GB). On Killercoda, expect a slower pull. If memory runs tight, swap to the lighter **OpenSearch** alternative shown at the end.

## Lab platform

Run all commands on the **Killercoda Ubuntu Playground**:

https://killercoda.com/playgrounds/scenario/ubuntu

> **Web tool:** Build and test the grok/regex patterns for Logstash with the free browser **Regex Generator** — https://alfredang.github.io/regexgenerator/ — before you put them in the pipeline config.

---

## Step 1 — Install Docker

```bash
apt update && apt install -y docker.io curl jq
systemctl start docker
sysctl -w vm.max_map_count=262144
```

---

## Step 2 — Run Elasticsearch

```bash
docker run -d --name es --net=host \
  -e discovery.type=single-node \
  -e xpack.security.enabled=false \
  -e ES_JAVA_OPTS='-Xms512m -Xmx512m' \
  docker.elastic.co/elasticsearch/elasticsearch:8.13.0
sleep 30
curl -s http://localhost:9200/_cluster/health | jq
```

---

## Step 3 — Run Kibana

```bash
docker run -d --name kibana --net=host \
  -e ELASTICSEARCH_HOSTS=http://localhost:9200 \
  docker.elastic.co/kibana/kibana:8.13.0
sleep 30
curl -s http://localhost:5601/api/status | head -c 200
```

Open `http://<killercoda-host>:5601` from the playground's Traffic tab.

---

## Step 4 — Run Logstash with a syslog input

> Ready-made file: [`pipeline.conf`](pipeline.conf) — you can download it instead of typing this block.

```bash
mkdir -p /tmp/ls && cat > /tmp/ls/pipeline.conf <<'EOF'
input { tcp { port => 5044 codec => line } }
filter { mutate { add_field => { "source" => "syslog" } } }
output { elasticsearch { hosts => ["http://localhost:9200"] index => "logs-%{+YYYY.MM.dd}" } }
EOF

docker run -d --name logstash --net=host \
  -v /tmp/ls/pipeline.conf:/usr/share/logstash/pipeline/logstash.conf \
  docker.elastic.co/logstash/logstash:8.13.0
sleep 25
```

---

## Step 5 — Ship test logs

```bash
for i in $(seq 1 20); do
  echo "$(date) cloudplus event $i severity=info" | nc -q 1 127.0.0.1 5044
done
sleep 3

curl -s 'http://localhost:9200/_cat/indices?v'
curl -s 'http://localhost:9200/logs-*/_search?q=event' | jq '.hits.total'
```

---

## Step 6 — Retention policy (ILM concept)

```bash
curl -s -X PUT http://localhost:9200/_ilm/policy/logs-retention \
  -H 'Content-Type: application/json' \
  -d '{
    "policy": {
      "phases": {
        "hot":   { "actions": {} },
        "delete": { "min_age": "7d", "actions": { "delete": {} } }
      }
    }
  }' | jq
```

This enforces **7-day retention** — a CV0-004 logging sub-objective.

---

## Step 7 — Aggregation query

```bash
curl -s -X POST http://localhost:9200/logs-*/_search \
  -H 'Content-Type: application/json' \
  -d '{"size":0,"aggs":{"by_severity":{"terms":{"field":"source.keyword"}}}}' | jq
```

---

## Step 8 — Cleanup

```bash
docker rm -f kibana logstash es
```

---

## OpenSearch alternative (lighter)

If ELK is too heavy:

```bash
docker run -d --name os -p 9200:9200 -p 9600:9600 \
  -e discovery.type=single-node \
  -e DISABLE_SECURITY_PLUGIN=true \
  opensearchproject/opensearch:latest
```

Same API. Same Kibana clone is OpenSearch Dashboards.

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
curl -s http://localhost:9200/_cluster/health | jq '.status'
curl -s 'http://localhost:9200/_cat/indices?v'
curl -s 'http://localhost:9200/logs-*/_search?q=event' | jq '.hits.total.value'
curl -s http://localhost:5601/api/status | head -c 200
curl -s http://localhost:9200/_ilm/policy/logs-retention | jq '.["logs-retention"].policy.phases.delete.min_age'
```

**Expected:** Run this before Step 8. Elasticsearch's cluster status is `"green"` or `"yellow"` (yellow is normal for single-node); `_cat/indices` lists a `logs-YYYY.MM.DD` index; the search reports a hit total of **20** — the 20 syslog lines Logstash ingested; Kibana's status shows `"level":"available"`; and the ILM policy returns `"7d"`, confirming the 7-day retention rule.

---

## What you learned
- Centralized logging pipeline: collect → ship → store → query.
- Retention is enforced with ILM policies.
- ELK and OpenSearch share the same query DSL.

## Free tools used
- Elasticsearch / Kibana / Logstash — https://www.elastic.co/elastic-stack
- OpenSearch — https://opensearch.org
- rsyslog — https://www.rsyslog.com

---

## Files in this lab

| File | Purpose |
|------|---------|
| [`pipeline.conf`](pipeline.conf) | Step 4 Logstash pipeline — TCP syslog input, mutate filter, Elasticsearch output. |
