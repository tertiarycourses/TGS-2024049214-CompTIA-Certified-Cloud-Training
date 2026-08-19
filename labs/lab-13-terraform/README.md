# Lab 13 — Infrastructure as Code with Terraform

In this lab you will write a Terraform configuration that provisions an S3 bucket and a security policy on **LocalStack** (free local AWS). You will see plan/apply, state, drift detection, and versioning.

## Lab platform

Run all commands on the **Killercoda Ubuntu Playground**:

https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Install Terraform and LocalStack

```bash
apt update && apt install -y wget unzip docker.io
systemctl start docker

wget -q https://releases.hashicorp.com/terraform/1.9.5/terraform_1.9.5_linux_amd64.zip
unzip -o terraform_1.9.5_linux_amd64.zip -d /usr/local/bin
terraform version

docker run -d --name localstack -p 4566:4566 -e SERVICES=s3,iam localstack/localstack:latest
sleep 8
```

---

## Step 2 — Write the Terraform configuration

> Ready-made file: [`main.tf`](main.tf) — you can download it instead of typing this block.

```bash
mkdir -p /tmp/tf && cd /tmp/tf
cat > main.tf <<'EOF'
terraform {
  required_providers { aws = { source = "hashicorp/aws" version = "~> 5.0" } }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true
  endpoints { s3 = "http://localhost:4566" iam = "http://localhost:4566" }
}

variable "env" { default = "dev" }

resource "aws_s3_bucket" "data" {
  bucket = "cloudplus-${var.env}-data"
}
EOF
```

---

## Step 3 — Init, plan, apply

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

Inspect state:

```bash
terraform state list
terraform state show aws_s3_bucket.data
ls -lh terraform.tfstate
```

The state file is the source of truth — back it up to a remote backend in production.

---

## Step 4 — Drift detection

Manually mutate the bucket outside Terraform:

```bash
docker exec localstack awslocal s3api put-bucket-tagging \
  --bucket cloudplus-dev-data \
  --tagging 'TagSet=[{Key=DriftedBy,Value=human}]'

terraform plan
```

`terraform plan` reports the **drift** — Terraform wants to remove the manual tag.

---

## Step 5 — Version your code (Git)

```bash
apt install -y git
cd /tmp/tf
git init -q
echo 'terraform.tfstate*' > .gitignore
echo '.terraform/' >> .gitignore
git add . && git -c user.email=lab@x -c user.name=lab commit -q -m "initial infra"
git log --oneline
```

Code reviewable, diff-able, rollback-able.

---

## Step 6 — Apply a change (test → apply pattern)

```bash
sed -i 's/env" { default = "dev"/env" { default = "prod"/' main.tf
terraform plan
terraform apply -auto-approve
terraform state list
```

Terraform creates `cloudplus-prod-data`. The dev one is destroyed because the resource name is parameterised — typical IaC behaviour.

---

## Step 7 — Cleanup

```bash
terraform destroy -auto-approve
docker rm -f localstack
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
cd /tmp/tf && terraform state list
terraform state show aws_s3_bucket.data | head -10
terraform plan -detailed-exitcode
docker exec localstack awslocal s3 ls
git -C /tmp/tf log --oneline
```

**Expected:** Run this before Step 7. `terraform state list` prints `aws_s3_bucket.data`; `state show` reports the bucket name (`cloudplus-prod-data` after Step 6); `terraform plan` reports **No changes. Your infrastructure matches the configuration** (exit code 0) once applied, or lists the drifted tag if you run it before re-applying; `awslocal s3 ls` shows the bucket really exists in LocalStack; and `git log` shows the `initial infra` commit.

---

## What you learned
- IaC: declarative config → cloud resources.
- Plan before apply.
- Drift detection catches manual changes.
- State must be stored safely.

## Free tools used
- Terraform — https://developer.hashicorp.com/terraform
- LocalStack Community — https://www.localstack.cloud
- OpenTofu (Terraform fork) — https://opentofu.org

---

## Files in this lab

| File | Purpose |
|------|---------|
| [`main.tf`](main.tf) | Step 2 Terraform config — LocalStack AWS provider plus the parameterised S3 bucket. |
