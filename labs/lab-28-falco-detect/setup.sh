#!/usr/bin/env bash
# Lab 28 — Detecting Suspicious Activity with Falco
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# Builds Step 1 and the Step 3 target container plus the Step 7 falcosidekick forwarder.
# The Step 3-5 detection triggers are what the learner must observe, so they are NOT run here.
set -euo pipefail

echo "==> Step 1: Installing Falco (modern eBPF mode)"
apt update && apt install -y curl gnupg lsb-release docker.io
systemctl start docker

curl -fsSL https://falco.org/repo/falcosecurity-packages.asc | gpg --dearmor -o /usr/share/keyrings/falco-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main" > /etc/apt/sources.list.d/falcosecurity.list
apt update
FALCO_DRIVER_CHOICE=modern_ebpf apt install -y falco
falco --version || true

echo "==> Step 1 (fallback): if kernel headers are missing, run Falco in a container instead"
if ! falco --version >/dev/null 2>&1; then
  docker run -d --name falco --privileged \
    -v /var/run/docker.sock:/host/var/run/docker.sock \
    -v /proc:/host/proc:ro \
    falcosecurity/falco-no-driver:latest /usr/bin/falco -o engine.kind=ebpf
fi

echo "==> Step 3: Starting the target container"
docker run -d --name target nginx:alpine

echo "==> Step 7: Starting falcosidekick for baseline-deviation alerting"
docker run -d --name fsk -p 2801:2801 \
  -e FALCO_LISTEN=0.0.0.0:2801 \
  falcosecurity/falcosidekick

echo
echo "You should now see: Falco reporting its version (or the falco container Up), the"
echo "'target' nginx container Up, and falcosidekick listening on port 2801."
echo "Next: tail Falco events (Step 2: 'journalctl -fu falco &' or 'docker logs -f falco &')"
echo "and fire the Step 3-5 triggers yourself — shell-in-container, /etc/shadow read and the"
echo "outbound wget — then 'bash cleanup.sh'."
