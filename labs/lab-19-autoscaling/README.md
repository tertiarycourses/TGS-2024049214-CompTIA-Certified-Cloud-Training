# Lab 19 — Horizontal Auto-Scaling Simulation

In this lab you will simulate triggered, scheduled, and manual scaling of a service with Docker Compose plus a Bash controller that watches CPU and adds/removes replicas — the same pattern every cloud auto-scaler uses.

## Lab platform

Run all commands on the **Killercoda Ubuntu Playground**:

https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Install Docker Compose and load tools

```bash
apt update && apt install -y docker.io docker-compose-v2 stress-ng bc curl
systemctl start docker
```

---

## Step 2 — Define a scalable service

> Ready-made file: [`docker-compose.yml`](docker-compose.yml) — you can download it instead of typing this block.

```bash
mkdir -p /tmp/scale && cd /tmp/scale
cat > docker-compose.yml <<'EOF'
services:
  app:
    image: nginx:alpine
    deploy: { replicas: 2 }
EOF
docker compose up -d --scale app=2
docker compose ps
```

---

## Step 3 — Triggered scaling (load-based)

This loop reads host CPU every 5 s and scales between 2 and 6 replicas.

> Ready-made file: [`autoscale.sh`](autoscale.sh) — you can download it instead of typing this block.

```bash
cat > /tmp/scale/autoscale.sh <<'EOF'
#!/bin/bash
cd /tmp/scale
MIN=2; MAX=6
while true; do
  CPU=$(awk -v cores=$(nproc) '/cpu / {usage=($2+$4)*100/($2+$4+$5)} END{print usage}' /proc/stat)
  CUR=$(docker compose ps -q app | wc -l)
  TARGET=$CUR
  awk -v c="$CPU" 'BEGIN{exit !(c+0 > 70)}' && [ $CUR -lt $MAX ] && TARGET=$((CUR+1))
  awk -v c="$CPU" 'BEGIN{exit !(c+0 < 20)}' && [ $CUR -gt $MIN ] && TARGET=$((CUR-1))
  if [ "$TARGET" != "$CUR" ]; then
    echo "$(date +%T) CPU=${CPU}%  scaling $CUR -> $TARGET"
    docker compose up -d --scale app=$TARGET --no-recreate
  fi
  sleep 5
done
EOF
chmod +x /tmp/scale/autoscale.sh
/tmp/scale/autoscale.sh &
ASPID=$!
```

Generate load:

```bash
stress-ng --cpu 4 --timeout 40s
sleep 60
```

You will see the controller scale **up** during stress and **down** afterwards. This is the **trending/load/event** trigger family from the exam objectives.

---

## Step 4 — Scheduled scaling

```bash
echo "*/1 * * * * cd /tmp/scale && docker compose up -d --scale app=4 --no-recreate" | crontab -
crontab -l
```

A cron-driven pre-scale is the "scheduled" approach — useful before a known traffic peak.

---

## Step 5 — Manual scaling

```bash
docker compose up -d --scale app=3 --no-recreate
docker compose ps
```

---

## Step 6 — Horizontal vs vertical

| Type | Action | Example |
|------|--------|---------|
| Horizontal | Add/remove replicas | This lab; AWS ASG, K8s HPA |
| Vertical | Resize a single instance | Stop/start with bigger CPU/RAM |

Horizontal is the cloud default because it survives instance loss and scales linearly.

---

## Step 7 — Cleanup

```bash
kill $ASPID 2>/dev/null
crontab -r 2>/dev/null
docker compose down
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
cd /tmp/scale && docker compose ps
docker compose ps -q app | wc -l
crontab -l
docker stats --no-stream --format '{{.Name}}\t{{.CPUPerc}}'
```

**Expected:** Run this before Step 7. `docker compose ps` shows every `app` replica **running**, the replica count sits between the controller's MIN of 2 and MAX of 6 (it rises toward 6 while `stress-ng` runs and falls back to 2 afterwards), `crontab -l` shows the scheduled `--scale app=4` entry, and `docker stats` reports live CPU for each replica.

---

## What you learned
- Triggered, scheduled, and manual scaling.
- A scaler is just a control loop watching a metric.
- Horizontal scaling is the cloud-native default.

## Free tools used
- Docker Compose — https://docs.docker.com/compose
- stress-ng — https://github.com/ColinIanKing/stress-ng
- cron (built-in)

---

## Files in this lab

| File | Purpose |
|------|---------|
| [`docker-compose.yml`](docker-compose.yml) | Step 2 Compose stack — the scalable `app` service. |
| [`autoscale.sh`](autoscale.sh) | Step 3 auto-scaling control loop — watches host CPU and scales between 2 and 6 replicas. |
