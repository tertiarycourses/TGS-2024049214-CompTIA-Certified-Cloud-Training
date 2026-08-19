#!/usr/bin/env bash
# Lab 9 — Public, Private & Hybrid Cloud Models — teardown (Step 7)
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
set -uo pipefail

echo "==> Step 7: Removing the LocalStack and MinIO containers"
docker rm -f public-cloud private-cloud || true

echo "==> Cleanup done — no public-cloud or private-cloud containers remain."
