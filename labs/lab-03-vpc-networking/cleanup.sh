#!/usr/bin/env bash
# Lab 3 — Cloud Networking with VPC Namespaces — teardown (Step 7)
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
set -uo pipefail

echo "==> Step 7: Removing namespaces, the NAT veth and the NAT rules"
ip netns del subnet-a || true
ip netns del subnet-b || true
ip netns del router || true
ip link del nat-r 2>/dev/null || true
iptables -t nat -F POSTROUTING || true

echo "==> Cleanup done — 'ip netns list' should now be empty."
