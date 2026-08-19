#!/usr/bin/env bash
# Lab 26 — Secrets Management with HashiCorp Vault
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# Builds Steps 1-5: Vault dev mode, static + versioned KV secrets, dynamic Postgres
# credentials and the file audit device.
set -euo pipefail

echo "==> Step 1: Running Vault in dev mode"
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

echo "==> Step 2: Writing and reading a static secret (KV v2)"
docker exec -e VAULT_TOKEN=cloudplus vault \
  vault kv put secret/app/db username=admin password=Sup3rSecret

docker exec -e VAULT_TOKEN=cloudplus vault \
  vault kv get secret/app/db

echo "==> Step 3: Versioned secrets (audit + rollback)"
docker exec -e VAULT_TOKEN=cloudplus vault \
  vault kv put secret/app/db username=admin password=Rotat3d!

docker exec -e VAULT_TOKEN=cloudplus vault \
  vault kv get -version=1 secret/app/db

echo "==> Step 4: Dynamic database credentials"
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

echo "==> Step 5: Enabling the file audit device (compliance)"
docker exec -e VAULT_TOKEN=cloudplus vault \
  vault audit enable file file_path=/vault/logs/audit.log

docker exec -e VAULT_TOKEN=cloudplus vault \
  vault kv get secret/app/db >/dev/null

docker exec vault tail -3 /vault/logs/audit.log

echo
echo "You should now see: Vault unsealed, secret/app/db at version 2 (Rotat3d!) with"
echo "version 1 (Sup3rSecret) still readable, a freshly minted 2-minute Postgres user from"
echo "database/creds/readonly, and JSON audit entries for each secret read."
echo "Next: read the Step 6 cloud-equivalents table, then 'bash cleanup.sh'."
