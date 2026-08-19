#!/usr/bin/env bash
# Lab 8 — Relational vs Non-Relational Databases — teardown (Step 7)
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
set -uo pipefail

echo "==> Step 7: Removing the Postgres and MongoDB containers"
docker rm -f pg mongo || true

echo "==> Cleanup done — no pg or mongo containers remain."
