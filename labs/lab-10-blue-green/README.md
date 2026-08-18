# Lab 10 — Blue-Green Deployment with Nginx

In this lab you will run two versions of an application — the live "blue" v1 and the staged "green" v2 — and switch traffic instantly by reloading Nginx. This is the canonical zero-downtime deployment pattern.

Run all commands on the Killercoda Ubuntu Playground:
https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Install Nginx and Docker

```bash
apt update && apt install -y nginx docker.io curl
systemctl start docker
systemctl start nginx
```

---

## Step 2 — Run Blue (v1) and Green (v2)

```bash
docker run -d --name blue  -p 8081:80 nginx:alpine
docker run -d --name green -p 8082:80 nginx:alpine

docker exec blue  sh -c 'echo "v1 BLUE"  > /usr/share/nginx/html/index.html'
docker exec green sh -c 'echo "v2 GREEN" > /usr/share/nginx/html/index.html'
```

---

## Step 3 — Point Nginx at Blue

```bash
cat > /etc/nginx/sites-available/default <<'EOF'
upstream live { server 127.0.0.1:8081; }   # BLUE
server {
    listen 80;
    location / { proxy_pass http://live; }
}
EOF
nginx -t && systemctl reload nginx
curl -s http://localhost/
```

---

## Step 4 — Smoke-test Green out of band

```bash
curl -s http://localhost:8082/
```

Green is fully running but receives **zero customer traffic**. Run integration tests here.

---

## Step 5 — Switch traffic to Green (cutover)

```bash
sed -i 's/8081/8082/' /etc/nginx/sites-available/default
nginx -t && systemctl reload nginx
for i in 1 2 3; do curl -s http://localhost/; done
```

`nginx -s reload` swaps without dropping a connection. Cutover is **atomic**.

---

## Step 6 — Instant rollback

If v2 is broken, switch back in one command:

```bash
sed -i 's/8082/8081/' /etc/nginx/sites-available/default
nginx -t && systemctl reload nginx
curl -s http://localhost/
```

This is why blue-green is preferred for high-risk releases.

---

## Step 7 — Cleanup

```bash
docker rm -f blue green
systemctl stop nginx
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
docker ps --filter name=blue --filter name=green --format '{{.Names}}\t{{.Status}}'
curl -s http://localhost:8081/
curl -s http://localhost:8082/
nginx -t
curl -s http://localhost/
```

**Expected:** Run this before Step 7. Both `blue` and `green` are **Up**; port 8081 returns `v1 BLUE` and port 8082 returns `v2 GREEN` (both environments live); `nginx -t` prints `syntax is ok` / `test is successful`; and port 80 returns whichever colour the upstream currently points at — `v1 BLUE` after the Step 6 rollback.

---

## What you learned
- Blue-green keeps two parallel environments; cutover is a config change.
- Rollback is symmetrical and fast.
- Smoke-test the new version on its own port before flipping traffic.

## Free tools used
- Nginx — https://nginx.org
- Docker — https://www.docker.com
