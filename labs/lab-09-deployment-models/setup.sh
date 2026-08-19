#!/usr/bin/env bash
# Lab 9 — Public, Private & Hybrid Cloud Models
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# Builds Steps 1-4: LocalStack as the "public" cloud, MinIO as the "private" cloud,
# and the hybrid object copy between them.
set -euo pipefail

echo "==> Step 1: Installing tools"
apt update && apt install -y docker.io awscli wireguard wireguard-tools
systemctl start docker

echo "==> Step 2: Standing up the 'public' cloud with LocalStack"
docker run -d --name public-cloud -p 4566:4566 \
  -e SERVICES=s3,ec2,iam \
  localstack/localstack:latest
sleep 8
curl -s http://localhost:4566/_localstack/health | head -c 200

echo
echo "==> Step 2: Pointing the AWS CLI at LocalStack"
aws configure set aws_access_key_id test
aws configure set aws_secret_access_key test
aws configure set default.region us-east-1

aws --endpoint-url=http://localhost:4566 s3 mb s3://public-bucket
aws --endpoint-url=http://localhost:4566 s3 ls

echo "==> Step 3: Standing up the 'private' cloud (on-prem MinIO)"
docker run -d --name private-cloud -p 9000:9000 \
  -e MINIO_ROOT_USER=admin -e MINIO_ROOT_PASSWORD=cloudplus \
  minio/minio server /data

sleep 4
docker exec private-cloud mc alias set local http://127.0.0.1:9000 admin cloudplus
docker exec private-cloud mc mb local/private-bucket

echo "==> Step 4: Hybrid — copying data between the two clouds"
echo "hybrid-payload" > /tmp/data.txt
aws --endpoint-url=http://localhost:4566 s3 cp /tmp/data.txt s3://public-bucket/
docker cp /tmp/data.txt private-cloud:/data.txt
docker exec private-cloud mc cp /data.txt local/private-bucket/

aws --endpoint-url=http://localhost:4566 s3 ls s3://public-bucket/
docker exec private-cloud mc ls local/private-bucket/

echo
echo "You should now see: LocalStack healthy with 'public-bucket', MinIO holding"
echo "'private-bucket', and the SAME data.txt object listed in both — the hybrid copy."
echo "Next: read Steps 5-6 in the README (community cloud, decision matrix), then 'bash cleanup.sh'."
