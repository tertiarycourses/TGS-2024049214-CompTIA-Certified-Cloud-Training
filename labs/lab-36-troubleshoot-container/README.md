# Lab 36 — Troubleshoot Container & Resource Limits

In this final lab you will combine the methods from Labs 33-35 to triage real container failures: **CrashLoopBackOff**, **OOMKilled**, image pull failures, hostname/DNS resolution inside containers, and read-only filesystem errors.

Run all commands on the Killercoda Ubuntu Playground:
https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Setup

```bash
apt update && apt install -y docker.io curl
systemctl start docker
```

---

## Step 2 — CrashLoopBackOff (process exits immediately)

```bash
docker run -d --name crash --restart=on-failure alpine sh -c "exit 1"
sleep 3
docker ps -a --filter name=crash
docker logs crash
```

Kubernetes equivalent:

```bash
echo "kubectl describe pod <name>  # look at 'Last State: Terminated, Reason'"
```

**Fix:** read logs, fix the entrypoint command, ensure the binary exists and exits 0.

---

## Step 3 — OOMKilled

```bash
docker run -d --name oom --memory=20m --restart=no alpine \
  sh -c "yes hello | head -c 100m"
sleep 3
docker inspect oom --format='{{.State.OOMKilled}} {{.State.ExitCode}} {{.State.Error}}'
docker rm -f oom
```

`OOMKilled=true` is the **smoking gun**. Fix: raise the limit (`--memory=128m`) or fix the leak.

---

## Step 4 — Image pull failure

```bash
docker run -d --name pull docker.io/myorg/no-such-image:1.0 2>&1 | tail -3
```

**Fix:** check image name, registry auth (`docker login`), private-registry credentials in K8s `imagePullSecrets`.

---

## Step 5 — DNS inside containers

```bash
docker run --rm alpine nslookup kubernetes.default 2>&1 | head -3
docker run --rm --dns 1.1.1.1 alpine nslookup example.com | tail -3
```

In K8s:

```bash
echo "kubectl exec -it <pod> -- nslookup kubernetes.default"
echo "If this fails -> CoreDNS down or NetworkPolicy blocking 53/udp."
```

---

## Step 6 — Read-only filesystem errors

```bash
docker run --rm --read-only alpine sh -c "echo x > /tmp/y" 2>&1 | tail -1
docker run --rm --read-only --tmpfs /tmp alpine sh -c "echo x > /tmp/y && cat /tmp/y"
```

Read-only roots are **good security** — give writable paths via `tmpfs` or volumes.

---

## Step 7 — Resource quota exhaustion (sizing)

```bash
docker run -d --name big --memory=2g --cpus=4 alpine sleep 1000 2>&1 || \
  echo "If host has insufficient resources -> pending / failed scheduling"
docker rm -f big 2>/dev/null
```

K8s analogue: `kubectl describe pod` → `FailedScheduling: 0/1 nodes available: insufficient memory`.

---

## Step 8 — End-to-end triage script

```bash
cat > /tmp/triage.sh <<'EOF'
#!/bin/bash
NAME=$1
echo "=== State ==="; docker inspect $NAME --format='{{.State.Status}} OOM={{.State.OOMKilled}} Exit={{.State.ExitCode}}'
echo "=== Logs (last 30) ==="; docker logs --tail 30 $NAME 2>&1
echo "=== Stats ==="; docker stats --no-stream $NAME 2>/dev/null
echo "=== Mounts ==="; docker inspect $NAME --format='{{range .Mounts}}{{.Source}} -> {{.Destination}} ({{.Mode}}){{println}}{{end}}'
echo "=== Network ==="; docker inspect $NAME --format='{{range $k,$v := .NetworkSettings.Networks}}{{$k}}={{$v.IPAddress}}{{end}}'
EOF
chmod +x /tmp/triage.sh

docker run -d --name demo nginx:alpine
/tmp/triage.sh demo
docker rm -f demo
```

---

## Step 9 — Master decision flow

1. **Pod won't start** → image pull, command, secrets.
2. **Pod crashloops** → application logs, exit code.
3. **Pod OOM** → resize memory, fix leak.
4. **Pod CPU throttled** → resize CPU, optimise code.
5. **Pod can't reach service** → DNS, NetworkPolicy, ServiceAccount RBAC.
6. **Pod read-only error** → mount tmpfs/volume.

---

## Step 10 — Closing summary

You have now hit every CV0-004 troubleshooting category:

| Category | Lab |
|----------|-----|
| Deployment | 33 |
| Network | 34 |
| Security | 35 |
| Container | 36 |

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
docker ps -a --filter name=crash --format '{{.Names}}\t{{.Status}}'
docker inspect oom --format='{{.State.OOMKilled}} {{.State.ExitCode}}'
docker run --rm --read-only --tmpfs /tmp alpine sh -c "echo x > /tmp/y && cat /tmp/y"
docker run --rm --dns 1.1.1.1 alpine nslookup example.com | tail -3
/tmp/triage.sh demo
```

**Expected:** Run each check while that step's container still exists. The `crash` container cycles through `Restarting (1)` / `Exited (1)` — the Docker equivalent of CrashLoopBackOff; `docker inspect oom` prints **`true 137`**, the OOMKilled smoking gun; the read-only container with a tmpfs mount succeeds and prints `x` where the plain `--read-only` run failed with *Read-only file system*; the DNS lookup resolves `example.com`; and `triage.sh demo` prints the State / Logs / Stats / Mounts / Network sections for the running nginx container.

---

## What you learned
- Read state, logs, stats, mounts, network — in that order.
- OOM, CrashLoop, ImagePull, DNS, RO-fs are the daily five.
- A short triage script saves 10 minutes per incident.

## Free tools used
- Docker — https://www.docker.com
- kubectl + k9s — https://k9scli.io
- ctop (container top) — https://github.com/bcicen/ctop
- lazydocker — https://github.com/jesseduffield/lazydocker
