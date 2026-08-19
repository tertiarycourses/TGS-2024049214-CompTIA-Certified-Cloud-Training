#!/usr/bin/env bash
# Lab 34 — Troubleshoot Cloud Network Issues — teardown
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# The README tears down inside Steps 4 and 5; this collects everything so a part-finished
# run leaves nothing behind.
set -uo pipefail

echo "==> Removing the 'web' container"
docker rm -f web 2>/dev/null || true

echo "==> Removing the Step 4 NAT rule and namespace"
iptables -t nat -D POSTROUTING -s 10.99.0.0/24 -o eth0 -j MASQUERADE 2>/dev/null || true
ip netns del p 2>/dev/null || true
ip link del veth0 2>/dev/null || true

echo "==> Removing the bad resolver file"
rm -f /tmp/bad-resolv.conf || true

echo "==> Cleanup done — port 8080 is free, namespace 'p' is gone and the MASQUERADE rule is removed."
