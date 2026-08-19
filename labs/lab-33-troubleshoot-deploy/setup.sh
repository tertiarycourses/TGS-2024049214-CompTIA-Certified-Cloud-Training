#!/usr/bin/env bash
# Lab 33 — Troubleshoot Deployment Issues
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# Builds Step 1 plus the long-lived containers the checks need: the Step 7 'web' container
# and the Step 8 'limit' responder, and pre-pulls the images used later.
# The deliberate failures (OOM kill, --read-only Postgres, CPU oversubscription) are what
# the learner must observe, so they are NOT run here.
set -euo pipefail

echo "==> Step 1: Setup"
apt update && apt install -y docker.io curl jq
systemctl start docker

echo "==> Pre-pulling the images used by Steps 2-8"
docker pull alpine 2>&1 | tail -1
docker pull alpine:3.10 2>&1 | tail -1
docker pull alpine:3.20 2>&1 | tail -1
docker pull nginx:alpine 2>&1 | tail -1
docker pull postgres:16 2>&1 | tail -1

echo "==> Step 7: Starting the 'web' container for the outage simulation"
docker run -d --name web -p 8080:80 nginx:alpine

echo "==> Step 8: Starting the 'limit' responder for the throttling exercise"
docker run -d --name limit -p 8081:80 \
  -e DELAY=0 nginx:alpine

echo
echo "You should now see: the 'web' container serving on :8080 and the 'limit' responder on"
echo ":8081, with alpine, alpine:3.10, alpine:3.20, nginx:alpine and postgres:16 all pulled."
echo "Next: work through Steps 2-9 in the README — each one reproduces a CV0-004 6.1 failure"
echo "mode you need to see fail before you apply the fix — then 'bash cleanup.sh'."
