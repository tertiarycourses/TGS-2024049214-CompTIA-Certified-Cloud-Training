#!/usr/bin/env bash
# Lab 27 — Web Application Firewall with ModSecurity
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# Builds Step 1: the Nginx + ModSecurity + OWASP CRS container.
# Steps 2-5 are the attack probes the learner must observe, so they are NOT run here.
set -euo pipefail

echo "==> Step 1: Running the pre-built Nginx + ModSecurity image"
apt update && apt install -y docker.io curl
systemctl start docker

docker run -d --name waf \
  -p 80:80 \
  -e BACKEND=http://example.com \
  -e PARANOIA=1 \
  owasp/modsecurity-crs:nginx
sleep 5
curl -sI http://localhost/

echo
echo "You should now see: the 'waf' container Up and Nginx answering on port 80 with the"
echo "OWASP Core Rule Set loaded at paranoia level 1."
echo "Next: run the Step 2-5 probes in the README yourself — the benign request returns 200"
echo "while the SQLi, XSS and path-traversal requests are blocked with 403 — then inspect"
echo "the audit log (Step 6), try the Step 7 tuning, and finish with 'bash cleanup.sh'."
