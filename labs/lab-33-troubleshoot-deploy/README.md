# Lab 33 — Troubleshoot Deployment Issues

In this lab you will reproduce and fix the deployment problems listed in CV0-004 6.1: **resource allocation, permissions, oversubscription, sizing, outdated definitions, deprecation, quotas, regional availability**.

## Lab platform

Run all commands on the **Killercoda Ubuntu Playground**:

https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Setup

```bash
apt update && apt install -y docker.io curl jq
systemctl start docker
```

---

## Step 2 — Resource allocation / sizing failure

```bash
docker run --rm --memory=10m alpine sh -c "yes | head -c 50m" 2>&1 | head -3
```

The container is OOM-killed because we under-sized memory.

```bash
docker stats --no-stream
```

**Fix:** raise the limit:

```bash
docker run --rm --memory=128m alpine sh -c "yes | head -c 50m >/dev/null && echo OK"
```

---

## Step 3 — Permission misconfiguration

```bash
docker run -d --name pg --read-only -e POSTGRES_PASSWORD=cloud postgres:16 2>&1 | tail -3
docker logs pg 2>&1 | tail -5
docker rm -f pg
```

Postgres needs a writable volume; `--read-only` blocks startup.

**Fix:** mount a writable tmpfs/volume:

```bash
docker run -d --name pg --read-only --tmpfs /var/run/postgresql --tmpfs /tmp \
  -v pgdata:/var/lib/postgresql/data -e POSTGRES_PASSWORD=cloud postgres:16
sleep 5 && docker logs pg | tail -3
docker rm -f pg && docker volume rm pgdata
```

---

## Step 4 — Oversubscription

```bash
docker run --rm --cpus=0.1 alpine sh -c "for i in 1 2 3 4 5; do dd if=/dev/zero of=/dev/null bs=1M count=200 & done; wait" 2>&1 | tail -3
```

CPU oversubscribed — work piles up in run queue. **Fix:** size CPU to peak load, not average.

---

## Step 5 — Outdated component definition (image)

```bash
docker pull alpine:3.10 2>&1 | tail -1
docker run --rm alpine:3.10 cat /etc/alpine-release
```

3.10 is end-of-life — outdated definition. **Fix:** pin to a supported tag (`alpine:3.20`).

---

## Step 6 — Deprecated functionality

```bash
docker run --rm alpine:3.20 sh -c 'echo "iptables-legacy still works:"; apk add --quiet iptables; iptables -L 2>&1 | head -3'
```

Some flags in `docker run` are deprecated (`--link`). Always check the changelog when an upgrade fails.

---

## Step 7 — Outage / partial outage simulation

```bash
docker run -d --name web -p 8080:80 nginx:alpine
docker pause web
curl -m 3 -sI http://localhost:8080 | head -1 || echo "PARTIAL OUTAGE: container paused"
docker unpause web
curl -sI http://localhost:8080 | head -1
docker rm -f web
```

---

## Step 8 — API throttling / service quota

Cloud APIs return HTTP **429 Too Many Requests** when throttled. Reproduce with a rate-limited responder:

```bash
docker run -d --name limit -p 8081:80 \
  -e DELAY=0 nginx:alpine

# Hammer it
for i in $(seq 1 50); do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8081/; done | sort | uniq -c
docker rm -f limit
```

**Fix in real cloud:** request a quota increase, add exponential backoff, batch calls.

---

## Step 9 — Regional service availability

Not every cloud service exists in every region. The fix is preventive — read the region matrix:

- AWS — https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/
- Azure — https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/
- GCP — https://cloud.google.com/about/locations

---

## Step 10 — Decision tree

1. Does the deployment **start**? → permissions, image, definition.
2. Does it **stay up**? → resources, OOM, CPU.
3. Does it **respond**? → quotas, throttling, availability.
4. Did it **work before**? → drift, deprecation, version skew.

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
docker run --rm --memory=128m alpine sh -c "yes | head -c 50m >/dev/null && echo OK"
docker run --rm alpine:3.10 cat /etc/alpine-release
docker ps -a --filter name=web --format '{{.Names}}\t{{.Status}}'
for i in $(seq 1 20); do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8081/; done | sort | uniq -c
docker stats --no-stream
```

**Expected:** Run each check at the point in the lab where its container still exists. The correctly-sized 128m container prints `OK` where the 10m one was OOM-killed; `alpine:3.10` prints `3.10.9` — an end-of-life release; the paused `web` container shows status `Up ... (Paused)` and `curl` times out until you `docker unpause` it and get `HTTP/1.1 200 OK`; and the 20 requests to the un-throttled responder all tally as `200` (a real cloud API would return `429` once the quota is hit).

---

## What you learned
- Reproduce each CV0-004 6.1 failure mode locally.
- Read logs/metrics first, fix the parameter that matches the symptom.
- Deprecation and EoL are deployment risks — track them.

## Free tools used
- Docker — https://www.docker.com
- AWS / Azure / GCP region matrices (linked above)
