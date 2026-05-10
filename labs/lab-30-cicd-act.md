# Lab 30 — CI/CD Pipeline with GitHub Actions (act)

In this lab you will build a CI/CD pipeline locally with **act** — a free tool that runs GitHub Actions workflows in Docker. The workflow tests, builds, scans, and "deploys" an artifact.

Run all commands on the Killercoda Ubuntu Playground:
https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Install Docker, git, and act

```bash
apt update && apt install -y docker.io git curl
systemctl start docker

curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | bash -s -- -b /usr/local/bin
act --version
```

---

## Step 2 — Sample repository with a Python app

```bash
mkdir -p /tmp/cicd && cd /tmp/cicd
git init -q -b main

cat > app.py <<'EOF'
def add(a,b): return a+b
EOF

cat > test_app.py <<'EOF'
from app import add
def test_add(): assert add(2,3) == 5
EOF

cat > Dockerfile <<'EOF'
FROM python:3.12-slim
COPY app.py /app/app.py
WORKDIR /app
CMD ["python", "-c", "from app import add; print(add(2,3))"]
EOF
```

---

## Step 3 — Define the workflow (.github/workflows/ci.yml)

```bash
mkdir -p .github/workflows
cat > .github/workflows/ci.yml <<'EOF'
name: ci
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: install
        run: pip install pytest
      - name: unit tests
        run: pytest -q
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: build image
        run: docker build -t myapp:${{ github.sha }} .
  scan:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: trivy fs
        run: |
          curl -sSL https://aquasecurity.github.io/trivy/install.sh | sh -s -- -b /usr/local/bin
          trivy fs --severity CRITICAL --exit-code 0 .
  deploy:
    needs: scan
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploying $GITHUB_SHA to staging"
EOF

git add . && git -c user.email=lab@x -c user.name=lab commit -q -m "ci"
```

---

## Step 4 — Run the workflow locally

```bash
act -j test
```

You will see Docker pull a runner image, install pytest, run the tests — green.

```bash
act -j build
act -j scan
act -j deploy
```

Or run the whole pipeline:

```bash
act
```

---

## Step 5 — Map to CV0-004 CI/CD concepts

| Stage in your YAML | Exam term |
|--------------------|-----------|
| `test` | Testing |
| `build` | Code integration + Build |
| `scan` | Security |
| `deploy` | Code deployment |
| `myapp:${{github.sha}}` | Artifact (container image) |
| `Dockerfile` | Packaging |

---

## Step 6 — Public vs private repositories

Push to GitHub:

```bash
# git remote add origin https://github.com/<you>/<repo>.git
# git push -u origin main
```

The same workflow runs on GitHub's hosted runners — public free for OSS, private free up to 2000 minutes/month.

---

## Step 7 — Other free CI options

| Tool | Type | Notes |
|------|------|-------|
| GitHub Actions | SaaS | 2000 free min/month private |
| GitLab CI | SaaS / self-hosted | 400 free CI min |
| Jenkins | Self-hosted | classic, plugin-rich |
| Drone CI | Self-hosted | Docker-native |
| Tekton | Self-hosted on K8s | cloud-native |

---

## Step 8 — Cleanup

```bash
rm -rf /tmp/cicd
```

---

## What you learned
- A pipeline is YAML + jobs + dependencies.
- act lets you iterate without pushing.
- Test → build → scan → deploy is the canonical flow.

## Free tools used
- act — https://github.com/nektos/act
- GitHub Actions — https://github.com/features/actions
- GitLab CI — https://docs.gitlab.com/ee/ci
- Jenkins — https://www.jenkins.io
- Drone — https://www.drone.io
