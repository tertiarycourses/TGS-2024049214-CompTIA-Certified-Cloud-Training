# Lab 12 — Rolling Deployment with Docker Compose

In this lab you will deploy three replicas of an app behind a load balancer, then upgrade them **one at a time** while traffic continues — the rolling deployment strategy used by Kubernetes Deployments, ECS services, and ASGs with rolling updates.

Run all commands on the Killercoda Ubuntu Playground:
https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Install Docker Compose

```bash
apt update && apt install -y docker.io docker-compose-v2 curl
systemctl start docker
```

---

## Step 2 — Define the stack

```bash
mkdir -p /tmp/rolling && cd /tmp/rolling
cat > docker-compose.yml <<'EOF'
services:
  app:
    image: nginx:alpine
    deploy:
      replicas: 3
    networks: [back]
    command: >
      sh -c 'echo "v1 from $$HOSTNAME" > /usr/share/nginx/html/index.html && nginx -g "daemon off;"'
  lb:
    image: haproxy:alpine
    ports: ["80:80"]
    volumes: ["./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro"]
    networks: [back]
networks:
  back:
EOF

cat > haproxy.cfg <<'EOF'
defaults
  mode http
  timeout connect 3s
  timeout client 30s
  timeout server 30s
frontend fe
  bind *:80
  default_backend app
backend app
  balance roundrobin
  server-template app- 3 app:80 check resolvers docker init-addr libc,none
resolvers docker
  nameserver dns 127.0.0.11:53
EOF

docker compose up -d --scale app=3
sleep 4
for i in 1 2 3 4 5 6; do curl -s http://localhost/; done
```

---

## Step 3 — Upgrade replicas one at a time

```bash
# Replica 1
CID=$(docker compose ps -q app | head -n1)
docker stop $CID && docker rm $CID
docker compose up -d --scale app=3 --no-recreate
sleep 2

# Replica 2
CID=$(docker compose ps -q app | sed -n 2p)
docker stop $CID && docker rm $CID
docker compose up -d --scale app=3 --no-recreate
sleep 2

# Replica 3
CID=$(docker compose ps -q app | tail -n1)
docker stop $CID && docker rm $CID
docker compose up -d --scale app=3 --no-recreate
sleep 2
```

While each is replaced, the other two keep serving — no downtime.

```bash
for i in $(seq 1 9); do curl -s http://localhost/; done
```

---

## Step 4 — Compare strategies

| Strategy | Resource use | Risk window | Rollback |
|----------|-------------|-------------|----------|
| In-place | 1× | Total downtime during swap | Restore + redeploy |
| Rolling | 1×–1.x× | Mixed versions during roll | Roll backwards |
| Blue-Green | 2× | Zero (atomic flip) | Instant |
| Canary | 1×–1.x× | Small % users | Reset weights |

---

## Step 5 — Cleanup

```bash
cd /tmp/rolling && docker compose down
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
cd /tmp/rolling && docker compose ps
docker compose ps -q app | wc -l
for i in $(seq 1 9); do curl -s http://localhost/; done
docker compose logs lb --tail 5
```

**Expected:** Run this before Step 5. `docker compose ps` shows the `lb` service plus the app replicas all in state **running**, the replica count is exactly `3`, and the nine `curl` calls return `v1 from <hostname>` cycling through three different container hostnames — proving HAProxy still balanced across surviving replicas while each one was replaced.

---

## What you learned
- Rolling = replace replicas one (or batch) at a time.
- Cheaper than blue-green but produces a brief mixed-version window.
- Always pair with a readiness check before progressing.

## Free tools used
- Docker Compose — https://docs.docker.com/compose
- HAProxy — https://www.haproxy.org
