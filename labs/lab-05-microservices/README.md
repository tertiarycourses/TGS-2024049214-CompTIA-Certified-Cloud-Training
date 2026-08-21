# Lab 5 — Microservices & Service Discovery

In this lab you will deploy three loosely-coupled microservices behind Consul for service discovery. You will see how containers register themselves, how a client resolves a service by name (not IP), and how the fan-out pattern works when one service calls many.

## Lab platform

Run all commands on the **Killercoda Ubuntu Playground**:

https://killercoda.com/playgrounds/scenario/ubuntu

> **Ready-made files:** this lab ships [`setup.sh`](setup.sh), [`cleanup.sh`](cleanup.sh) and [`service-users.json`](service-users.json) — run `bash setup.sh` to build everything in one go, or follow the steps below to type it yourself.

---

## Step 1 — Install Docker and create a network

```bash
apt update && apt install -y docker.io curl jq
systemctl start docker
docker network create cloudnet
```

---

## Step 2 — Run Consul (service registry)

```bash
docker run -d --name consul --network cloudnet \
  -p 8500:8500 hashicorp/consul:latest \
  agent -dev -client=0.0.0.0
sleep 3
curl -s http://localhost:8500/v1/status/leader
```

---

## Step 3 — Deploy three microservices

Each service is a tiny HTTP responder.

```bash
for n in users orders payments; do
  docker run -d --name svc-$n --network cloudnet \
    -e PORT=80 \
    nginx:alpine
  docker exec svc-$n sh -c "echo '{\"service\":\"$n\",\"ok\":true}' > /usr/share/nginx/html/index.html"
done
```

---

## Step 4 — Register them with Consul

```bash
for n in users orders payments; do
  curl -s -X PUT -d "{
    \"Name\": \"$n\",
    \"Address\": \"svc-$n\",
    \"Port\": 80,
    \"Check\": {\"HTTP\": \"http://svc-$n/\", \"Interval\": \"10s\"}
  }" http://localhost:8500/v1/agent/service/register
done

curl -s http://localhost:8500/v1/catalog/services | jq
```

---

## Step 5 — Discover a service by name (DNS interface)

Consul exposes service names over DNS on port 8600.

```bash
docker run --rm --network cloudnet --dns 8.8.8.8 alpine \
  sh -c "ping -c 2 consul && wget -qO- http://consul:8500/v1/health/service/users"
```

Clients now resolve `users.service.consul` instead of hard-coded IPs — the **service discovery** primitive of every cloud-native platform.

---

## Step 6 — Fan-out call

Simulate one request triggering parallel calls to all three services (event fan-out).

```bash
docker run --rm --network cloudnet alpine sh -c "
  apk add --quiet curl
  for s in users orders payments; do
    (curl -s http://svc-$s/ &)
  done
  wait
"
```

---

## Step 7 — Loosely coupled: kill one service, others survive

```bash
docker stop svc-orders
curl -s http://localhost:8500/v1/health/service/users | jq '.[].Checks[].Status'
curl -s http://localhost:8500/v1/health/service/orders | jq '.[].Checks[].Status'
```

`users` stays `passing`, `orders` flips to `critical` — but the rest of the system keeps running. That is **loose coupling**.

---

## Step 8 — Cleanup

```bash
docker rm -f consul svc-users svc-orders svc-payments
docker network rm cloudnet
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
curl -s http://localhost:8500/v1/status/leader
curl -s http://localhost:8500/v1/catalog/services | jq
curl -s http://localhost:8500/v1/health/service/users | jq '.[].Checks[].Status'
docker ps --filter name=svc- --format '{{.Names}}\t{{.Status}}'
```

**Expected:** Run this before Step 8. Consul returns a leader address such as `"127.0.0.1:8300"`, the catalog lists `users`, `orders` and `payments` alongside `consul`, the `users` health check returns `"passing"`, and all three `svc-*` containers are **Up** (after Step 7, `svc-orders` is stopped and its check reads `"critical"` while `users` stays `"passing"` — that is the loose coupling).

---

## What you learned
- Microservices register and deregister with a service registry.
- Clients resolve services by name, not IP — IPs come and go.
- Fan-out and loose coupling are key cloud-native design patterns.

## Free tools used
- HashiCorp Consul — https://www.consul.io
- Docker — https://www.docker.com

---

## Files in this lab

| File | Purpose |
|------|---------|
| [`setup.sh`](setup.sh) | Runs Steps 1-4 — creates the `cloudnet` network, starts Consul, deploys the three microservices and registers them. |
| [`cleanup.sh`](cleanup.sh) | Step 8 teardown — removes the Consul and `svc-*` containers and the `cloudnet` network. |
| [`service-users.json`](service-users.json) | Step 4 Consul service definition for `users`, extracted from the registration loop. |
