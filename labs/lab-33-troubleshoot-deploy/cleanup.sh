#!/usr/bin/env bash
# Lab 33 — Troubleshoot Deployment Issues — teardown
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# The README removes each container inline within its own step; this collects them all so a
# part-finished run leaves nothing behind.
set -uo pipefail

echo "==> Removing the lab containers"
docker rm -f web limit pg 2>/dev/null || true

echo "==> Removing the Step 3 volume"
docker volume rm pgdata 2>/dev/null || true

echo "==> Cleanup done — ports 8080 and 8081 are free and no lab containers remain."
