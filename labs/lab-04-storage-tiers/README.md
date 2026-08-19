# Lab 4 — Storage Tiers (Block, Object, File)

In this lab you will create one of each cloud storage type on the Killercoda VM: a **block** device with a loopback file, an **object** store with MinIO (S3-compatible), and a **file** share with NFS. You will then measure IOPS with `fio` to see why hot/warm/cold tiering exists.

## Lab platform

Run all commands on the **Killercoda Ubuntu Playground**:

https://killercoda.com/playgrounds/scenario/ubuntu

> **Ready-made files:** this lab ships [`setup.sh`](setup.sh) and [`cleanup.sh`](cleanup.sh) — run `bash setup.sh` to build everything in one go, or follow the steps below to type it yourself.

---

## Step 1 — Install tools

```bash
apt update && apt install -y fio nfs-kernel-server nfs-common docker.io
systemctl start docker
```

---

## Step 2 — Create a BLOCK device (like AWS EBS)

```bash
dd if=/dev/zero of=/tmp/disk.img bs=1M count=256
LOOP=$(losetup -f --show /tmp/disk.img)
mkfs.ext4 $LOOP
mkdir -p /mnt/block
mount $LOOP /mnt/block
df -h /mnt/block
```

Block storage = raw device, formatted with a filesystem, mounted to a single VM.

---

## Step 3 — Create an OBJECT store (like AWS S3)

```bash
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
```

Object storage = HTTP API, infinite scale, no filesystem, accessed by key.

---

## Step 4 — Create a FILE share (like AWS EFS / Azure Files)

```bash
mkdir -p /srv/nfs && chmod 777 /srv/nfs
echo '/srv/nfs *(rw,sync,no_subtree_check,no_root_squash)' > /etc/exports
exportfs -ra
systemctl start nfs-kernel-server

mkdir -p /mnt/file
mount -t nfs 127.0.0.1:/srv/nfs /mnt/file
echo "shared" > /mnt/file/test.txt
cat /srv/nfs/test.txt
```

File storage = POSIX filesystem, shared by many clients over NFS or SMB.

---

## Step 5 — Compare IOPS between tiers (hot vs cold)

```bash
echo "--- BLOCK (hot, SSD-like) ---"
fio --name=hot --filename=/mnt/block/test --size=64M --rw=randwrite --bs=4k --runtime=5 --time_based --group_reporting | grep IOPS

echo "--- FILE over NFS (warm) ---"
fio --name=warm --filename=/mnt/file/test --size=64M --rw=randwrite --bs=4k --runtime=5 --time_based --group_reporting | grep IOPS
```

You will see block storage delivers significantly higher random-write IOPS than NFS — this is why **hot** tier (SSD block) costs more than **warm** (file) and far more than **cold/archive** (object).

---

## Step 6 — Tier mapping

| Tier | Cloud example | This lab |
|------|--------------|----------|
| Hot (SSD block) | AWS gp3, Azure Premium SSD | `/mnt/block` (ext4) |
| Warm (file) | AWS EFS, Azure Files | `/mnt/file` (NFS) |
| Cold (object std) | AWS S3 Standard | MinIO `hot-bucket` |
| Archive | AWS Glacier, Azure Archive | MinIO with lifecycle |

---

## Step 7 — Cleanup

```bash
umount /mnt/block /mnt/file
losetup -d $LOOP
docker rm -f minio
systemctl stop nfs-kernel-server
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
df -h /mnt/block /mnt/file
mount | grep -E 'loop|nfs'
docker exec minio mc ls local/hot-bucket/
cat /srv/nfs/test.txt
exportfs -v
```

**Expected:** Run this before Step 7. `/mnt/block` shows a ~250M ext4 filesystem on a `/dev/loop*` device and `/mnt/file` shows the `127.0.0.1:/srv/nfs` NFS mount; `mc ls` lists `file.txt` in `hot-bucket`; `cat` prints `shared` (proving the NFS write landed in `/srv/nfs`); and `exportfs -v` shows `/srv/nfs` exported with `rw`.

---

## What you learned
- Block, object, and file storage have different APIs and access patterns.
- IOPS varies by an order of magnitude between tiers.
- Cost models follow performance — hot is fastest and most expensive.

## Free tools used
- MinIO — https://min.io
- NFS kernel server (built-in)
- fio — https://github.com/axboe/fio

---

## Files in this lab

| File | Purpose |
|------|---------|
| [`setup.sh`](setup.sh) | Runs Steps 1-4 — installs fio/NFS/Docker, builds the loopback block device, starts MinIO with `hot-bucket`, and exports the NFS share. |
| [`cleanup.sh`](cleanup.sh) | Step 7 teardown — unmounts `/mnt/block` and `/mnt/file`, detaches the loop device, removes MinIO and stops the NFS server. |
