#!/usr/bin/env bash
# Lab 20 — Backup & Recovery with restic — teardown (Step 11)
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
set -uo pipefail

echo "==> Step 11: Removing MinIO and the source/restore directories"
docker rm -f minio || true
rm -rf /data/app /restore || true

echo "==> Cleanup done — the MinIO repository target and the lab data are gone."
