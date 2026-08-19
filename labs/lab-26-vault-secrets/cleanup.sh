#!/usr/bin/env bash
# Lab 26 — Secrets Management with HashiCorp Vault — teardown (Step 7)
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
set -uo pipefail

echo "==> Step 7: Removing the Vault and Postgres containers"
docker rm -f vault pg || true

echo "==> Cleanup done — Vault (and every dev-mode secret in it) and Postgres are gone."
