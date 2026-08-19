#!/usr/bin/env bash
# Lab 27 — Web Application Firewall with ModSecurity — teardown (Step 9)
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
set -uo pipefail

echo "==> Step 9: Removing the WAF container"
docker rm -f waf || true

echo "==> Cleanup done — port 80 is free and the waf container is gone."
