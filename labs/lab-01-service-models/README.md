# Lab 1 — Cloud Service Models & Shared Responsibility

In this lab you will compare IaaS, PaaS, SaaS, and FaaS by running the equivalent of each model **locally** on the Killercoda Ubuntu Playground. You will provision a raw VM-style workload (IaaS), deploy a managed Postgres-like service (PaaS), use a SaaS-style web app, and run a Function-as-a-Service handler. By the end you will be able to explain who is responsible for what under the **shared responsibility model**.

Run all commands on the Killercoda Ubuntu Playground:
https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Update and install base tools

```bash
apt update && apt install -y docker.io curl jq python3-pip
systemctl start docker
```

Docker will let us simulate cloud-managed services as containers. `curl` and `jq` are used to call APIs.

---

## Step 2 — IaaS simulation (you manage everything above the hypervisor)

Run a bare Ubuntu container — you patch it, you secure it, you install the runtime. This mirrors AWS EC2 / Azure VM / GCP Compute Engine.

```bash
docker run -dit --name iaas-vm ubuntu:22.04 bash
docker exec iaas-vm apt update
docker exec iaas-vm apt install -y nginx
docker exec iaas-vm service nginx start
```

You installed the OS package, configured the service, and started it. Under IaaS the **customer owns OS, runtime, app, data** and the **provider owns hardware, hypervisor, network**.

---

## Step 3 — PaaS simulation (provider manages the runtime)

Run a managed-style Postgres. You only supply the database name and password — no OS patching.

```bash
docker run -d --name paas-db -e POSTGRES_PASSWORD=cloud -p 5432:5432 postgres:16
sleep 5
docker exec paas-db psql -U postgres -c "CREATE DATABASE app;"
```

You did not install Postgres, configure `pg_hba.conf`, or apply OS patches. Under PaaS the **provider owns OS + runtime**, the **customer owns app + data**.

---

## Step 4 — SaaS simulation (you only consume)

Run a fully packaged app — Nextcloud — the way you would consume Microsoft 365 or Salesforce.

```bash
docker run -d --name saas-app -p 8080:80 nextcloud:latest
sleep 10
curl -sI http://localhost:8080 | head -3
```

You did not write code, manage runtime, or touch the database. Under SaaS the **provider owns everything except your data and access**.

---

## Step 5 — FaaS simulation (event-driven function)

Install OpenFaaS-style local handler with a Python script that runs on demand — like AWS Lambda.

```bash
mkdir -p /tmp/faas && cat > /tmp/faas/handler.py <<'EOF'
import sys, json
event = json.loads(sys.stdin.read())
print(json.dumps({"hello": event.get("name", "cloud")}))
EOF

echo '{"name":"Cloud+"}' | python3 /tmp/faas/handler.py
```

The function runs only when invoked, scales to zero, and bills per-invocation. The **provider owns the entire execution environment**; you only own the function code.

---

## Step 6 — Map responsibility

Fill in the matrix from what you just ran:

| Layer | IaaS | PaaS | SaaS | FaaS |
|-------|------|------|------|------|
| Data | You | You | You | You |
| Application | You | You | Provider | You (code only) |
| Runtime | You | Provider | Provider | Provider |
| OS | You | Provider | Provider | Provider |
| Hypervisor / Hardware | Provider | Provider | Provider | Provider |

---

## Step 7 — Cleanup

```bash
docker rm -f iaas-vm paas-db saas-app
```

---

## What you learned
- Hands-on difference between IaaS, PaaS, SaaS, and FaaS.
- Who patches the OS, who owns the data, and who runs the runtime in each model.
- The shared responsibility model is **never** "the provider does it all".

## Free tools used
- Docker — https://www.docker.com
- Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
- AWS Shared Responsibility Model (reading) — https://aws.amazon.com/compliance/shared-responsibility-model/
