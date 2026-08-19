# Lab 26 — Secrets Management with HashiCorp Vault

In this lab you will run **HashiCorp Vault** in dev mode, store secrets, generate dynamic database credentials, and rotate them — the secrets-management sub-objective of CV0-004.

## Lab platform

Run all commands on the **Killercoda Ubuntu Playground**:

https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Run Vault in dev mode

```bash
apt update && apt install -y docker.io curl jq
systemctl start docker

docker run -d --name vault \
  --cap-add IPC_LOCK -p 8200:8200 \
  -e 'VAULT_DEV_ROOT_TOKEN_ID=cloudplus' \
  -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200' \
  hashicorp/vault:latest
sleep 4

export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=cloudplus
docker exec vault vault status
```

---

## Step 2 — Write and read a static secret (KV v2)

```bash
docker exec -e VAULT_TOKEN=cloudplus vault \
  vault kv put secret/app/db username=admin password=Sup3rSecret

docker exec -e VAULT_TOKEN=cloudplus vault \
  vault kv get secret/app/db
```

Hard-coded secrets in code → ❌. Reference from Vault → ✅.

---

## Step 3 — Versioned secrets (audit + rollback)

```bash
docker exec -e VAULT_TOKEN=cloudplus vault \
  vault kv put secret/app/db username=admin password=Rotat3d!

docker exec -e VAULT_TOKEN=cloudplus vault \
  vault kv get -version=1 secret/app/db
```

You just rolled back to v1. Versioning is built in.

---

## Step 4 — Dynamic database credentials

Run a Postgres + tell Vault to mint **short-lived** users on demand.

```bash
docker run -d --name pg --network=host -e POSTGRES_PASSWORD=root postgres:16
sleep 5

docker exec -e VAULT_TOKEN=cloudplus vault sh -c '
  vault secrets enable database
  vault write database/config/pg \
    plugin_name=postgresql-database-plugin \
    allowed_roles="readonly" \
    connection_url="postgresql://{{username}}:{{password}}@host.docker.internal:5432/postgres?sslmode=disable" \
    username="postgres" password="root"
  vault write database/roles/readonly \
    db_name=pg \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD \"{{password}}\" VALID UNTIL \"{{expiration}}\"; GRANT pg_read_all_data TO \"{{name}}\";" \
    default_ttl="2m" max_ttl="5m"
'

docker exec -e VAULT_TOKEN=cloudplus vault vault read database/creds/readonly
```

You now have a **2-minute-lifetime** Postgres user. After 2 minutes Vault deletes it. Compromise risk → near zero.

---

## Step 5 — Audit log (compliance)

```bash
docker exec -e VAULT_TOKEN=cloudplus vault \
  vault audit enable file file_path=/vault/logs/audit.log

docker exec -e VAULT_TOKEN=cloudplus vault \
  vault kv get secret/app/db >/dev/null

docker exec vault tail -3 /vault/logs/audit.log
```

Every secret access is logged. SOC2 / PCI-DSS love this.

---

## Step 6 — Cloud equivalents

| Tool | Equivalent service |
|------|-------------------|
| Vault | AWS Secrets Manager, AWS SSM Parameter Store, Azure Key Vault, GCP Secret Manager |
| Vault dynamic DB role | RDS IAM auth, Azure Managed Identity for SQL |

---

## Step 7 — Cleanup

```bash
docker rm -f vault pg
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
docker exec vault vault status
docker exec -e VAULT_TOKEN=cloudplus vault vault kv get secret/app/db
docker exec -e VAULT_TOKEN=cloudplus vault vault kv get -version=1 secret/app/db
docker exec -e VAULT_TOKEN=cloudplus vault vault read database/creds/readonly
docker exec vault tail -3 /vault/logs/audit.log
```

**Expected:** Run this before Step 7. `vault status` shows `Sealed  false` and `Initialized  true`; the current secret reads back at **version 2** with `password  Rotat3d!` while `-version=1` still returns `Sup3rSecret` (versioned rollback works); `database/creds/readonly` mints a fresh username like `v-root-readonly-<random>` with `lease_duration  2m`; and the audit log tail shows JSON entries recording each secret read.

---

## What you learned
- Static and dynamic secrets.
- Versioning, audit, lease/expiry.
- Dynamic creds collapse the blast radius of leaked passwords.

## Free tools used
- HashiCorp Vault — https://www.vaultproject.io
- SOPS (alternative) — https://github.com/getsops/sops
- age (file encryption) — https://github.com/FiloSottile/age
- Mozilla SOPS + age + git — common GitOps secrets pattern
