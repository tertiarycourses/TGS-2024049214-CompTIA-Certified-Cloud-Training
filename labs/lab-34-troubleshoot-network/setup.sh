#!/usr/bin/env bash
# Lab 34 — Troubleshoot Cloud Network Issues
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# Builds Step 1 plus the Step 5 'web' container the HTTP status checks need, and writes the
# Step 2 bad-resolver file.
# The deliberate failures (SERVFAIL resolver, missing NAT, 404) are what the learner must
# observe, so the probes themselves are NOT run here.
set -euo pipefail

echo "==> Step 1: Installing diagnostics"
apt update && apt install -y dnsutils iproute2 iputils-ping curl traceroute mtr-tiny tcpdump iptables docker.io chrony jq
systemctl start docker

echo "==> Step 2: Writing the deliberately-broken resolver file"
echo "nameserver 192.0.2.1" > /tmp/bad-resolv.conf

echo "==> Step 5: Starting the 'web' container for HTTP status triage"
docker run -d --name web -p 8080:80 nginx:alpine

echo
echo "You should now see: the diagnostic toolchain installed (dig, mtr, traceroute, tcpdump,"
echo "chrony), /tmp/bad-resolv.conf holding the unreachable 192.0.2.1 resolver, and the 'web'"
echo "container serving on :8080."
echo "Next: work through Steps 2-9 in the README — each reproduces a CV0-004 6.2 failure you"
echo "need to see fail before applying the fix — then 'bash cleanup.sh'."
