#!/usr/bin/env bash
# Lab 5 — Microservices & Service Discovery
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# Builds Steps 1-4: the cloudnet network, Consul, three microservices and their registrations.
set -euo pipefail

echo "==> Step 1: Installing Docker and creating a network"
apt update && apt install -y docker.io curl jq
systemctl start docker
docker network create cloudnet

echo "==> Step 2: Running Consul (service registry)"
docker run -d --name consul --network cloudnet \
  -p 8500:8500 hashicorp/consul:latest \
  agent -dev -client=0.0.0.0
sleep 3
curl -s http://localhost:8500/v1/status/leader

echo "==> Step 3: Deploying three microservices"
for n in users orders payments; do
  docker run -d --name svc-$n --network cloudnet \
    -e PORT=80 \
    nginx:alpine
  docker exec svc-$n sh -c "echo '{\"service\":\"$n\",\"ok\":true}' > /usr/share/nginx/html/index.html"
done

echo "==> Step 4: Registering them with Consul"
for n in users orders payments; do
  curl -s -X PUT -d "{
    \"Name\": \"$n\",
    \"Address\": \"svc-$n\",
    \"Port\": 80,
    \"Check\": {\"HTTP\": \"http://svc-$n/\", \"Interval\": \"10s\"}
  }" http://localhost:8500/v1/agent/service/register
done

curl -s http://localhost:8500/v1/catalog/services | jq

echo
echo "You should now see: Consul returning a leader address, the catalog listing users,"
echo "orders and payments, and three svc-* containers Up on the cloudnet network."
echo "Next: work through Steps 5-7 in the README (DNS discovery, fan-out, kill a service),"
echo "then 'bash cleanup.sh'."
