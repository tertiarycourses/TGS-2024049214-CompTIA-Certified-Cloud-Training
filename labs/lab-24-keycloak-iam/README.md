# Lab 24 — IAM & RBAC with Keycloak

In this lab you will run **Keycloak** (open-source identity provider), create a realm, users, roles, and an OAuth 2.0 client — the building blocks of cloud IAM (federation, SAML, OIDC, RBAC).

## Lab platform

Run all commands on the **Killercoda Ubuntu Playground**:

https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Run Keycloak

```bash
apt update && apt install -y docker.io curl jq
systemctl start docker

docker run -d --name kc -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  quay.io/keycloak/keycloak:25.0 start-dev
sleep 25
curl -sI http://localhost:8080/realms/master | head -1
```

UI: `http://<killercoda-host>:8080`.

---

## Step 2 — Get an admin token

```bash
TOKEN=$(curl -s -X POST http://localhost:8080/realms/master/protocol/openid-connect/token \
  -d "username=admin" -d "password=admin" -d "grant_type=password" -d "client_id=admin-cli" \
  | jq -r .access_token)
echo "$TOKEN" | head -c 40
```

This is an **OIDC** access token. Cloud admin CLIs do exactly the same call against AWS Cognito / Azure AD / GCP Identity.

---

## Step 3 — Create a realm (= a tenant)

```bash
curl -s -X POST http://localhost:8080/admin/realms \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"realm":"cloudplus","enabled":true}'
```

---

## Step 4 — Create roles (RBAC)

```bash
for role in viewer operator admin; do
  curl -s -X POST http://localhost:8080/admin/realms/cloudplus/roles \
    -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
    -d "{\"name\":\"$role\"}"
done

curl -s http://localhost:8080/admin/realms/cloudplus/roles \
  -H "Authorization: Bearer $TOKEN" | jq '.[].name'
```

---

## Step 5 — Create a user and assign a role

```bash
curl -s -X POST http://localhost:8080/admin/realms/cloudplus/users \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"username":"alice","enabled":true,"credentials":[{"type":"password","value":"cloud","temporary":false}]}'

UID=$(curl -s "http://localhost:8080/admin/realms/cloudplus/users?username=alice" \
  -H "Authorization: Bearer $TOKEN" | jq -r '.[0].id')

ROLE=$(curl -s http://localhost:8080/admin/realms/cloudplus/roles/operator \
  -H "Authorization: Bearer $TOKEN")

curl -s -X POST http://localhost:8080/admin/realms/cloudplus/users/$UID/role-mappings/realm \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d "[$ROLE]"
```

---

## Step 6 — Create an OAuth 2.0 client

```bash
curl -s -X POST http://localhost:8080/admin/realms/cloudplus/clients \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"clientId":"cli-app","publicClient":true,"directAccessGrantsEnabled":true,"redirectUris":["*"]}'
```

---

## Step 7 — Authenticate as Alice (token-based)

```bash
ALICE_TOKEN=$(curl -s -X POST http://localhost:8080/realms/cloudplus/protocol/openid-connect/token \
  -d "username=alice" -d "password=cloud" -d "grant_type=password" -d "client_id=cli-app" \
  | jq -r .access_token)

# Decode the JWT payload
echo "$ALICE_TOKEN" | cut -d. -f2 | base64 -d 2>/dev/null | jq .realm_access
```

The payload includes `realm_access.roles: ["operator"]` — that is **role-based access control**.

---

## Step 8 — Authentication models map

| Exam term | Where you saw it |
|-----------|------------------|
| Local users | `username/password` in Keycloak |
| Federation / SAML | Keycloak → external IdP |
| OpenID Connect / OIDC | the `/protocol/openid-connect/*` endpoints |
| Token-based | bearer JWT |
| Directory-based | LDAP user federation in Keycloak |
| MFA | OTP setting per user (Lab 25) |

---

## Step 9 — Cleanup

```bash
docker rm -f kc
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
curl -sI http://localhost:8080/realms/master | head -1
curl -s http://localhost:8080/admin/realms -H "Authorization: Bearer $TOKEN" | jq '.[].realm'
curl -s http://localhost:8080/admin/realms/cloudplus/roles -H "Authorization: Bearer $TOKEN" | jq '.[].name'
curl -s "http://localhost:8080/admin/realms/cloudplus/users?username=alice" -H "Authorization: Bearer $TOKEN" | jq '.[].username'
echo "$ALICE_TOKEN" | cut -d. -f2 | base64 -d 2>/dev/null | jq .realm_access
```

**Expected:** Run this before Step 9. Keycloak answers `HTTP/1.1 200 OK` on the master realm; the realm list includes `"cloudplus"` next to `"master"`; the role list contains `viewer`, `operator` and `admin`; the user query returns `"alice"`; and Alice's decoded JWT payload shows `"roles"` containing **`"operator"`** — the RBAC assignment travelled in the token claim.

---

## What you learned
- Identity provider, realms, users, roles, clients.
- OAuth 2.0 + OIDC token flow.
- RBAC roles propagate via JWT claims.

## Free tools used
- Keycloak — https://www.keycloak.org
- jwt.io decoder (web) — https://jwt.io
- OAuth.tools — https://oauth.tools
