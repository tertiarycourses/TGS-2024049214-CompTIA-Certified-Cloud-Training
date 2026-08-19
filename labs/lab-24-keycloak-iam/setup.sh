#!/usr/bin/env bash
# Lab 24 — IAM & RBAC with Keycloak
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# Builds Steps 1-7: Keycloak, the cloudplus realm, RBAC roles, user alice, the OAuth client
# and Alice's token.
set -euo pipefail

echo "==> Step 1: Running Keycloak"
apt update && apt install -y docker.io curl jq
systemctl start docker

docker run -d --name kc -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  quay.io/keycloak/keycloak:25.0 start-dev
sleep 25
curl -sI http://localhost:8080/realms/master | head -1

echo "==> Step 2: Getting an admin token"
TOKEN=$(curl -s -X POST http://localhost:8080/realms/master/protocol/openid-connect/token \
  -d "username=admin" -d "password=admin" -d "grant_type=password" -d "client_id=admin-cli" \
  | jq -r .access_token)
echo "$TOKEN" | head -c 40
echo

echo "==> Step 3: Creating the cloudplus realm (= a tenant)"
curl -s -X POST http://localhost:8080/admin/realms \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"realm":"cloudplus","enabled":true}'

echo "==> Step 4: Creating roles (RBAC)"
for role in viewer operator admin; do
  curl -s -X POST http://localhost:8080/admin/realms/cloudplus/roles \
    -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
    -d "{\"name\":\"$role\"}"
done

curl -s http://localhost:8080/admin/realms/cloudplus/roles \
  -H "Authorization: Bearer $TOKEN" | jq '.[].name'

echo "==> Step 5: Creating user alice and assigning the operator role"
curl -s -X POST http://localhost:8080/admin/realms/cloudplus/users \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"username":"alice","enabled":true,"credentials":[{"type":"password","value":"cloud","temporary":false}]}'

# NOTE: the README uses $UID here; in a bash script UID is a readonly shell variable,
# so this script uses USER_ID for the identical value.
USER_ID=$(curl -s "http://localhost:8080/admin/realms/cloudplus/users?username=alice" \
  -H "Authorization: Bearer $TOKEN" | jq -r '.[0].id')

ROLE=$(curl -s http://localhost:8080/admin/realms/cloudplus/roles/operator \
  -H "Authorization: Bearer $TOKEN")

curl -s -X POST http://localhost:8080/admin/realms/cloudplus/users/$USER_ID/role-mappings/realm \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d "[$ROLE]"

echo "==> Step 6: Creating the OAuth 2.0 client"
curl -s -X POST http://localhost:8080/admin/realms/cloudplus/clients \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"clientId":"cli-app","publicClient":true,"directAccessGrantsEnabled":true,"redirectUris":["*"]}'

echo "==> Step 7: Authenticating as Alice and decoding her JWT"
ALICE_TOKEN=$(curl -s -X POST http://localhost:8080/realms/cloudplus/protocol/openid-connect/token \
  -d "username=alice" -d "password=cloud" -d "grant_type=password" -d "client_id=cli-app" \
  | jq -r .access_token)

echo "$ALICE_TOKEN" | cut -d. -f2 | base64 -d 2>/dev/null | jq .realm_access

echo
echo "You should now see: Keycloak Up on port 8080, a 'cloudplus' realm with the viewer/"
echo "operator/admin roles, the user alice, the cli-app client, and Alice's decoded token"
echo "carrying realm_access.roles = [\"operator\"]."
echo "Next: the README's 'Test it' checks re-use \$TOKEN and \$ALICE_TOKEN — re-run Steps 2"
echo "and 7 in your own shell to set them, then 'bash cleanup.sh'."
