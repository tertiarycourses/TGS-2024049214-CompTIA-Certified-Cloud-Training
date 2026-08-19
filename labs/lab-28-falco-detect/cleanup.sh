#!/usr/bin/env bash
# Lab 28 — Detecting Suspicious Activity with Falco — teardown (Step 8)
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# The README also kills the Step 2 journalctl tail ($JLP) — do that in the shell that started it.
set -uo pipefail

echo "==> Step 8: Removing the target, falco and falcosidekick containers"
docker rm -f target falco fsk 2>/dev/null || true

echo "==> Cleanup done — stop the Step 2 log tail with 'kill \$JLP' in the shell that started it."
