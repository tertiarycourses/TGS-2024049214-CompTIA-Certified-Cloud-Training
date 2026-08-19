#!/usr/bin/env bash
# Lab 25 — Bastion Host with SSH Key + MFA — teardown (Step 8)
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
set -uo pipefail

echo "==> Step 8: Removing the app container and reverting the SSH/PAM MFA config"
docker rm -f app || true
sed -i '/AuthenticationMethods/d' /etc/ssh/sshd_config || true
sed -i '/pam_google_authenticator/d' /etc/pam.d/sshd || true
systemctl restart ssh || true
ufw disable 2>/dev/null || true

echo "==> Cleanup done — SSH no longer chains the TOTP factor and ufw is disabled."
