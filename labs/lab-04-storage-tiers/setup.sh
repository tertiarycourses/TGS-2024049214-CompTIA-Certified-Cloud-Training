#!/usr/bin/env bash
# Lab 4 — Storage Tiers (Block, Object, File)
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# Builds Steps 1-4: the loopback block device, the MinIO object store and the NFS file share.
set -euo pipefail

echo "==> Step 1: Installing tools"
apt update && apt install -y fio nfs-kernel-server nfs-common docker.io
systemctl start docker

echo "==> Step 2: Creating a BLOCK device (like AWS EBS)"
dd if=/dev/zero of=/tmp/disk.img bs=1M count=256
LOOP=$(losetup -f --show /tmp/disk.img)
mkfs.ext4 $LOOP
mkdir -p /mnt/block
mount $LOOP /mnt/block
df -h /mnt/block

# Record the loop device so cleanup.sh can detach it
echo "$LOOP" > /tmp/lab04-loop

echo "==> Step 3: Creating an OBJECT store (like AWS S3)"
docker run -d --name minio -p 9000:9000 -p 9001:9001 \
  -e MINIO_ROOT_USER=admin -e MINIO_ROOT_PASSWORD=cloudplus \
  minio/minio server /data --console-address ":9001"

sleep 5

docker exec minio mc alias set local http://127.0.0.1:9000 admin cloudplus
docker exec minio mc mb local/hot-bucket
echo "Hello Cloud+" > /tmp/file.txt
docker cp /tmp/file.txt minio:/file.txt
docker exec minio mc cp /file.txt local/hot-bucket/
docker exec minio mc ls local/hot-bucket/

echo "==> Step 4: Creating a FILE share (like AWS EFS / Azure Files)"
mkdir -p /srv/nfs && chmod 777 /srv/nfs
echo '/srv/nfs *(rw,sync,no_subtree_check,no_root_squash)' > /etc/exports
exportfs -ra
systemctl start nfs-kernel-server

mkdir -p /mnt/file
mount -t nfs 127.0.0.1:/srv/nfs /mnt/file
echo "shared" > /mnt/file/test.txt
cat /srv/nfs/test.txt

echo
echo "You should now see: /mnt/block (ext4 on a loop device), /mnt/file (NFS mount),"
echo "and file.txt inside the MinIO 'hot-bucket'."
echo "Next: run the Step 5 fio IOPS comparison from the README, then 'bash cleanup.sh'."
