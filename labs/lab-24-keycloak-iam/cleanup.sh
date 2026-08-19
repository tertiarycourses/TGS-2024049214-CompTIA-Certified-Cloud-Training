#!/usr/bin/env bash
# Lab 24 — IAM & RBAC with Keycloak — teardown (Step 9)
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
set -uo pipefail

echo "==> Step 9: Removing the Keycloak container"
docker rm -f kc || true

echo "==> Cleanup done — the kc container and the cloudplus realm inside it are gone."
