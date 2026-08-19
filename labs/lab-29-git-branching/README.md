# Lab 29 — Git Source Control & Branching

In this lab you will exercise every CV0-004 source-control verb: **commit, push, branch, merge, pull request review** — using a local Gitea server as your "GitHub clone".

## Lab platform

Run all commands on the **Killercoda Ubuntu Playground**:

https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Install git and run Gitea (self-hosted)

```bash
apt update && apt install -y git docker.io curl jq
systemctl start docker

docker run -d --name gitea -p 3000:3000 -p 2222:22 gitea/gitea:latest
sleep 25
curl -sI http://localhost:3000 | head -1
```

UI: `http://<killercoda-host>:3000` — set up admin user (e.g. `admin`/`cloudplus`/`a@x.com`) on first visit.

---

## Step 2 — Create a repository (UI or API)

```bash
curl -s -u admin:cloudplus -X POST http://localhost:3000/api/v1/user/repos \
  -H 'Content-Type: application/json' \
  -d '{"name":"infra","auto_init":true,"default_branch":"main"}' | jq .full_name
```

---

## Step 3 — Clone, commit, push

> Ready-made file: [`main.tf`](main.tf) — you can download it instead of typing this block.

```bash
mkdir -p /tmp/work && cd /tmp/work
git clone http://admin:cloudplus@localhost:3000/admin/infra.git
cd infra
git config user.email lab@x
git config user.name lab

cat > main.tf <<'EOF'
resource "aws_s3_bucket" "data" { bucket = "main-bucket" }
EOF
git add main.tf
git commit -m "feat: initial bucket"
git push origin main
```

---

## Step 4 — Branch management

> Ready-made file: [`encryption.tf.snippet`](encryption.tf.snippet) — you can download it instead of typing this block.

```bash
git checkout -b feature/encryption
cat >> main.tf <<'EOF'
resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule { apply_server_side_encryption_by_default { sse_algorithm = "AES256" } }
}
EOF
git commit -am "feat: add SSE"
git push origin feature/encryption
```

---

## Step 5 — Open a Pull Request

```bash
curl -s -u admin:cloudplus -X POST http://localhost:3000/api/v1/repos/admin/infra/pulls \
  -H 'Content-Type: application/json' \
  -d '{"title":"Add SSE","head":"feature/encryption","base":"main","body":"Encrypts the bucket"}'
```

Open the PR in the UI and review the diff — that is the **code review** sub-objective.

---

## Step 6 — Merge

```bash
PR=1
curl -s -u admin:cloudplus -X POST http://localhost:3000/api/v1/repos/admin/infra/pulls/$PR/merge \
  -H 'Content-Type: application/json' \
  -d '{"Do":"merge"}'

git checkout main
git pull
cat main.tf | tail -5
```

---

## Step 7 — Resolve a merge conflict

```bash
git checkout -b feature/region
sed -i 's/main-bucket/main-bucket-us/' main.tf
git commit -am "feat: rename to us"
git push origin feature/region

git checkout main
sed -i 's/main-bucket/main-bucket-eu/' main.tf
git commit -am "feat: rename to eu"
git push origin main

git merge feature/region || true
grep -n '<<<' main.tf
# resolve
sed -i 's/<<<<<<<.*//; s/=======.*//; s/>>>>>>>.*//' main.tf
git commit -am "merge: keep eu"
```

---

## Step 8 — Branch protection (concept)

In production, protect `main`:
- Require PR + 1 approval.
- Require CI green.
- Block force-push.

These map to the exam's **branch management** sub-objective.

---

## Step 9 — Cleanup

```bash
docker rm -f gitea
rm -rf /tmp/work
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
curl -sI http://localhost:3000 | head -1
curl -s -u admin:cloudplus http://localhost:3000/api/v1/repos/admin/infra/branches | jq '.[].name'
curl -s -u admin:cloudplus http://localhost:3000/api/v1/repos/admin/infra/pulls?state=all | jq '.[] | {title, state}'
cd /tmp/work/infra && git log --oneline --graph --all | head -15
grep -c '<<<<<<<' main.tf
```

**Expected:** Run this before Step 9. Gitea returns `HTTP/1.1 200 OK`; the branch list contains `main`, `feature/encryption` and `feature/region`; the PR query shows `{"title":"Add SSE","state":"closed"}` — closed because it was merged; the commit graph shows the feature branches joining `main` at a merge commit; and `grep -c` returns `0`, proving the conflict markers were resolved before the final commit.

---

## What you learned
- Commit → push → branch → PR → merge.
- Conflict resolution is a normal Git workflow.
- Branch protection enforces the review policy.

## Free tools used
- git (built-in) — https://git-scm.com
- Gitea — https://about.gitea.com
- GitHub (free public repos) — https://github.com
- GitLab Community — https://about.gitlab.com
- Pro Git book (free) — https://git-scm.com/book

---

## Files in this lab

| File | Purpose |
|------|---------|
| [`main.tf`](main.tf) | Step 3 initial Terraform file committed to the Gitea repo. |
| [`encryption.tf.snippet`](encryption.tf.snippet) | Step 4 block appended to `main.tf` on the `feature/encryption` branch. |
