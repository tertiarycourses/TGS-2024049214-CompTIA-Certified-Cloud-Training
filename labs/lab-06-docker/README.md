# Lab 6 — Containerization with Docker

In this lab you will build a custom image, run a stand-alone container, expose ports, mount persistent and ephemeral storage, and push to a local registry. By the end you will have practised every CV0-004 containerization sub-objective.

Run all commands on the Killercoda Ubuntu Playground:
https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Install Docker

```bash
apt update && apt install -y docker.io
systemctl start docker
docker --version
```

---

## Step 2 — Build a custom image

```bash
mkdir -p /tmp/app && cd /tmp/app
cat > index.html <<'EOF'
<h1>Cloud+ container</h1>
EOF
cat > Dockerfile <<'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF

docker build -t myapp:1.0 .
docker images | grep myapp
```

---

## Step 3 — Stand-alone run with port mapping

```bash
docker run -d --name web -p 8080:80 myapp:1.0
curl -s http://localhost:8080
```

`-p 8080:80` maps host port 8080 → container port 80. This is **port mapping**, a CV0-004 sub-objective.

---

## Step 4 — Ephemeral storage (default)

```bash
docker exec web sh -c 'echo lost > /tmp/scratch.txt'
docker exec web cat /tmp/scratch.txt
docker rm -f web
docker run -d --name web -p 8080:80 myapp:1.0
docker exec web ls /tmp/scratch.txt 2>&1 || echo "Gone — ephemeral"
```

The file disappeared with the container — that is **ephemeral storage**.

---

## Step 5 — Persistent volume

```bash
docker volume create app-data
docker rm -f web
docker run -d --name web -p 8080:80 \
  -v app-data:/data myapp:1.0
docker exec web sh -c 'echo durable > /data/keep.txt'
docker rm -f web
docker run --rm -v app-data:/data alpine cat /data/keep.txt
```

The file survived a container delete — that is a **persistent volume**.

---

## Step 6 — Pull from a public image registry

```bash
docker pull alpine:3.20
docker pull hello-world
docker images
```

`docker.io` is a **public** registry. You can also push to private registries like ECR, ACR, GAR.

---

## Step 7 — Run a private registry

```bash
docker run -d --name registry -p 5000:5000 registry:2
docker tag myapp:1.0 localhost:5000/myapp:1.0
docker push localhost:5000/myapp:1.0
docker pull localhost:5000/myapp:1.0
curl -s http://localhost:5000/v2/_catalog
```

---

## Step 8 — Workload orchestration preview (Compose)

```bash
apt install -y docker-compose-v2 || apt install -y docker-compose
cat > /tmp/docker-compose.yml <<'EOF'
services:
  web:
    image: myapp:1.0
    ports: ["8081:80"]
  cache:
    image: redis:7-alpine
EOF
cd /tmp && docker compose up -d
docker compose ps
```

This previews **workload orchestration** — covered fully in Lab 32 (Kubernetes).

---

## Step 9 — Cleanup

```bash
cd / && docker compose -f /tmp/docker-compose.yml down
docker rm -f web registry
docker volume rm app-data
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
docker images | grep -E 'myapp|alpine|hello-world'
curl -s http://localhost:8080
docker run --rm -v app-data:/data alpine cat /data/keep.txt
curl -s http://localhost:5000/v2/_catalog
docker compose -f /tmp/docker-compose.yml ps
```

**Expected:** Run this before Step 9. `myapp:1.0` (plus `alpine:3.20` and `hello-world`) appear in the image list; `curl` on port 8080 returns `<h1>Cloud+ container</h1>`; the volume read prints `durable`, proving the named volume outlived the container; the local registry catalog returns `{"repositories":["myapp"]}`; and `docker compose ps` shows the `web` and `cache` services running.

---

## What you learned
- Build, tag, run, and push images.
- Port mapping vs persistent volumes vs ephemeral storage.
- Public vs private image registries.

## Free tools used
- Docker Engine — https://www.docker.com
- Docker Hub — https://hub.docker.com
- Distribution registry — https://github.com/distribution/distribution
