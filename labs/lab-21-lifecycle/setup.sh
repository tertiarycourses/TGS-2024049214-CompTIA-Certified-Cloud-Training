#!/usr/bin/env bash
# Lab 21 — Patching & Lifecycle Management
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# Builds Steps 1-5: patching tools, the provisioned web container, the major-version swap
# and the persistent-volume demonstration. (Step 7's decommission lives in cleanup.sh.)
set -euo pipefail

echo "==> Step 1: Installing patching tools"
apt update && apt install -y unattended-upgrades apt-listchanges docker.io
systemctl start docker

echo "==> Step 2: Provision phase"
docker run -d --name web --label lifecycle=active nginx:1.24-alpine
docker inspect -f '{{.Config.Image}}' web

echo "==> Step 3: Applying MINOR patches (simulated)"
apt-get -s upgrade | head -20             # simulate
unattended-upgrade --dry-run -d 2>&1 | tail -10

echo "==> Step 4: MAJOR upgrade — staging the new version side-by-side"
docker run -d --name web-new nginx:1.27-alpine
docker exec web-new nginx -v

echo "==> Step 4: Smoke test before the swap"
curl -sI http://$(docker inspect -f '{{(index .NetworkSettings.Networks "bridge").IPAddress}}' web-new)/ | head -1

echo "==> Step 4: Swapping (blue-green style)"
docker rm -f web
docker rename web-new web

echo "==> Step 5: Persistent vs ephemeral data during upgrade"
docker volume create app-data
docker run -d --name app2 -v app-data:/var/lib/app nginx:alpine
docker exec app2 sh -c 'echo persistent > /var/lib/app/keep.txt'
docker rm -f app2
docker run --rm -v app-data:/var/lib/app alpine cat /var/lib/app/keep.txt

echo
echo "You should now see: the 'web' container running nginx:1.27-alpine after the swap, and"
echo "the app-data volume still printing 'persistent' — data survived the container replacement."
echo "Next: work through Steps 6-7 in the README (EoL images, decommission), then 'bash cleanup.sh'."
