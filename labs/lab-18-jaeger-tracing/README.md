# Lab 18 — Distributed Tracing with Jaeger

In this lab you will run Jaeger all-in-one, instrument a small Python script with OpenTelemetry, and view a distributed trace in the Jaeger UI — covering the exam's tracing sub-objective.

Run all commands on the Killercoda Ubuntu Playground:
https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Install Docker, Python deps

```bash
apt update && apt install -y docker.io python3-pip curl
systemctl start docker
pip3 install opentelemetry-api opentelemetry-sdk opentelemetry-exporter-otlp-proto-grpc requests
```

---

## Step 2 — Run Jaeger

```bash
docker run -d --name jaeger --net=host \
  jaegertracing/all-in-one:latest
sleep 5
curl -sI http://localhost:16686 | head -1
```

UI: `http://<killercoda-host>:16686`.

---

## Step 3 — Instrument a "checkout" microservice path

```bash
mkdir -p /tmp/trace && cd /tmp/trace
cat > app.py <<'EOF'
import time, random
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

trace.set_tracer_provider(TracerProvider())
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(OTLPSpanExporter(endpoint="localhost:4317", insecure=True))
)
tracer = trace.get_tracer("shop")

def db_lookup():
    with tracer.start_as_current_span("db.lookup"):
        time.sleep(random.uniform(0.05, 0.2))

def charge():
    with tracer.start_as_current_span("payment.charge"):
        time.sleep(random.uniform(0.1, 0.3))

def checkout():
    with tracer.start_as_current_span("http.checkout"):
        db_lookup()
        charge()

for _ in range(5):
    checkout()
    time.sleep(0.3)
print("traces sent")
EOF

python3 app.py
```

---

## Step 4 — Query traces via Jaeger API

```bash
sleep 5
curl -s "http://localhost:16686/api/traces?service=shop&limit=5" | head -c 400
```

Open the UI, choose **service = shop**, **operation = http.checkout**, click a trace — you will see the parent span with two child spans (`db.lookup`, `payment.charge`) and their durations.

---

## Step 5 — How tracing helps incident triage

A trace shows the **critical path** of a single request across all services. When a user reports "checkout is slow," you find the slowest span instead of guessing which service is at fault — this is why tracing is the third pillar of observability.

| Symptom | Pillar that solves it |
|---------|----------------------|
| "CPU is high on host X" | Metrics (Lab 16) |
| "We had a 500 error at 10:42" | Logs (Lab 17) |
| "Why is *this specific request* slow?" | Traces (Lab 18) |

---

## Step 6 — Cleanup

```bash
docker rm -f jaeger
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
curl -sI http://localhost:16686 | head -1
curl -s "http://localhost:16686/api/services" | jq '.data'
curl -s "http://localhost:16686/api/traces?service=shop&limit=5" | jq '.data | length'
curl -s "http://localhost:16686/api/traces?service=shop&limit=1" | jq '[.data[0].spans[].operationName]'
```

**Expected:** Run this before Step 6. Jaeger's UI returns `HTTP/1.1 200 OK`, the services list includes `"shop"`, the trace query returns **5 traces** (one per `checkout()` iteration), and each trace's span list contains `http.checkout` with its two children `db.lookup` and `payment.charge`.

---

## What you learned
- Spans are the unit of tracing; traces are causally-linked spans.
- OpenTelemetry is the vendor-neutral instrumentation API.
- Tracing answers "where did this one request spend its time?".

## Free tools used
- Jaeger — https://www.jaegertracing.io
- OpenTelemetry — https://opentelemetry.io
- Zipkin (alternative) — https://zipkin.io
