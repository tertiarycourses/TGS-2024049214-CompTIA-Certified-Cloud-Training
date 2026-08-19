#!/usr/bin/env bash
# Lab 20 — Backup & Recovery with restic
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# Builds Steps 1-3: restic + MinIO off-site target, the encrypted repo and the FULL backup.
set -euo pipefail

echo "==> Step 1: Installing restic and MinIO (off-site target)"
apt update && apt install -y restic docker.io
systemctl start docker

docker run -d --name minio -p 9000:9000 \
  -e MINIO_ROOT_USER=admin -e MINIO_ROOT_PASSWORD=cloudplus \
  minio/minio server /data
sleep 4
docker exec minio mc alias set local http://127.0.0.1:9000 admin cloudplus
docker exec minio mc mb local/backups

echo "==> Step 2: Configuring restic to talk to S3-compatible storage"
export RESTIC_REPOSITORY="s3:http://localhost:9000/backups"
export AWS_ACCESS_KEY_ID=admin
export AWS_SECRET_ACCESS_KEY=cloudplus
export RESTIC_PASSWORD=cloudplus

restic init

echo "==> Step 3: Creating source data and taking a FULL backup"
mkdir -p /data/app && for i in 1 2 3; do
  dd if=/dev/urandom of=/data/app/file$i bs=1M count=2 2>/dev/null
done
restic backup /data/app --tag full
restic snapshots

echo
echo "You should now see: MinIO Up with a 'backups' bucket, an initialised encrypted restic"
echo "repository, and one snapshot tagged 'full'."
echo "Next: export the same four RESTIC_/AWS_ variables in your shell (this script's exports"
echo "do not survive it), then work through Steps 4-10 in the README, then 'bash cleanup.sh'."
