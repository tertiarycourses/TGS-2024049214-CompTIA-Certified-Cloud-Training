#!/usr/bin/env bash
# Lab 5 — Microservices & Service Discovery — teardown (Step 8)
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
set -uo pipefail

echo "==> Step 8: Removing the containers and the cloudnet network"
docker rm -f consul svc-users svc-orders svc-payments || true
docker network rm cloudnet || true

echo "==> Cleanup done — no consul or svc-* containers remain."
