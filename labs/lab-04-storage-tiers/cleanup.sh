#!/usr/bin/env bash
# Lab 4 — Storage Tiers (Block, Object, File) — teardown (Step 7)
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
set -uo pipefail

LOOP=$(cat /tmp/lab04-loop 2>/dev/null || true)

echo "==> Step 7: Unmounting, detaching the loop device and removing MinIO"
umount /mnt/block /mnt/file || true
[ -n "$LOOP" ] && losetup -d "$LOOP" || true
docker rm -f minio || true
systemctl stop nfs-kernel-server || true

echo "==> Cleanup done — /mnt/block and /mnt/file are unmounted and MinIO is gone."
