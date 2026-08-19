#!/usr/bin/env bash
# Lab 21 — Patching & Lifecycle Management — decommission (Step 7)
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# Tag/snapshot first, then destroy — the archival commit is part of decommissioning.
set -uo pipefail

echo "==> Step 7: Committing the archival snapshot"
docker commit web web-decom-$(date +%Y%m%d) || true
docker images | grep decom || true

echo "==> Step 7: Destroying the container, volume and old image"
docker rm -f web || true
docker volume rm app-data || true
docker rmi nginx:1.24-alpine 2>/dev/null || true

echo "==> Cleanup done — the web container and app-data volume are gone; the"
echo "    web-decom-<date> image remains as the archival snapshot."
