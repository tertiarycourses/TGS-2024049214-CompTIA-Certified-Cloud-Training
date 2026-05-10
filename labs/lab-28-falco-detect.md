# Lab 28 — Detecting Suspicious Activity with Falco

In this lab you will run **Falco** — a CNCF runtime security tool — and trigger detections for shell-in-container, sensitive-file reads, unexpected outbound connections, and cryptojacking-style behaviour.

Run all commands on the Killercoda Ubuntu Playground:
https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Install Falco (modern eBPF mode)

```bash
apt update && apt install -y curl gnupg lsb-release docker.io
systemctl start docker

curl -fsSL https://falco.org/repo/falcosecurity-packages.asc | gpg --dearmor -o /usr/share/keyrings/falco-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main" > /etc/apt/sources.list.d/falcosecurity.list
apt update
FALCO_DRIVER_CHOICE=modern_ebpf apt install -y falco
falco --version
```

If kernel headers are missing on Killercoda, run Falco in **userspace** mode in a container:

```bash
docker run -d --name falco --privileged \
  -v /var/run/docker.sock:/host/var/run/docker.sock \
  -v /proc:/host/proc:ro \
  falcosecurity/falco-no-driver:latest /usr/bin/falco -o engine.kind=ebpf
```

---

## Step 2 — Tail Falco events

```bash
journalctl -fu falco &
JLP=$!
```

(or `docker logs -f falco &`)

---

## Step 3 — Trigger: shell spawned in a container

```bash
docker run -d --name target nginx:alpine
docker exec target sh -c 'echo "shell inside container"'
```

Falco fires:

```
Notice A shell was spawned in a container ... container_id=...
```

---

## Step 4 — Trigger: read of a sensitive file

```bash
docker exec target cat /etc/shadow
```

Falco rule **Read sensitive file untrusted** fires.

---

## Step 5 — Trigger: unexpected outbound connection

```bash
docker exec target sh -c 'wget -q http://example.com -O /dev/null'
```

Falco rule **Unexpected outbound connection** fires (in default rules).

---

## Step 6 — Map to attack types from the exam

| Detection | Maps to exam category |
|-----------|----------------------|
| Shell in container | Vulnerability exploitation |
| /etc/shadow read | Privilege escalation |
| Outbound connect | Cryptojacking / zombie instance |
| Sudden CPU spike (Lab 16) | Cryptojacking |
| Unexpected metadata API call | Metadata abuse (cloud-specific) |

---

## Step 7 — Baseline deviation alerting

Fold Falco events into Prometheus (Lab 16) via `falcosidekick`:

```bash
docker run -d --name fsk -p 2801:2801 \
  -e FALCO_LISTEN=0.0.0.0:2801 \
  falcosecurity/falcosidekick
```

Then in `falco.yaml` set `http_output: enabled: true, url: http://falcosidekick:2801`.

---

## Step 8 — Cleanup

```bash
kill $JLP 2>/dev/null
docker rm -f target falco fsk 2>/dev/null
```

---

## What you learned
- Runtime detection uses kernel signals (eBPF) to spot bad behaviour.
- Common detections map to CV0-004 attack categories.
- Falco events flow into Prometheus / SIEM.

## Free tools used
- Falco — https://falco.org
- Falcosidekick — https://github.com/falcosecurity/falcosidekick
- auditd (built-in) — https://github.com/linux-audit/audit-userspace
- Wazuh (free SIEM) — https://wazuh.com
