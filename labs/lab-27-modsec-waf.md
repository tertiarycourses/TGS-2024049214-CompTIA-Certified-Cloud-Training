# Lab 27 — Web Application Firewall with ModSecurity

In this lab you will deploy **Nginx + ModSecurity + the OWASP Core Rule Set (CRS)** and watch it block SQL injection, XSS, and path-traversal attempts.

Run all commands on the Killercoda Ubuntu Playground:
https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Run a pre-built Nginx + ModSecurity image

```bash
apt update && apt install -y docker.io curl
systemctl start docker

docker run -d --name waf \
  -p 80:80 \
  -e BACKEND=http://example.com \
  -e PARANOIA=1 \
  owasp/modsecurity-crs:nginx
sleep 5
curl -sI http://localhost/
```

This image bundles Nginx + libmodsecurity + OWASP CRS — the same WAF logic AWS WAF and Cloudflare WAF base their managed rules on.

---

## Step 2 — Run a benign request (allowed)

```bash
curl -s -o /dev/null -w "%{http_code}\n" "http://localhost/?q=cats"
```

---

## Step 3 — Trigger a SQL injection rule

```bash
curl -s -o /dev/null -w "%{http_code}\n" "http://localhost/?id=1' OR '1'='1"
```

You should see **403** — CRS rule 942100 (SQLi).

---

## Step 4 — Trigger an XSS rule

```bash
curl -s -o /dev/null -w "%{http_code}\n" "http://localhost/?msg=<script>alert(1)</script>"
```

403 — CRS rule 941100 (XSS).

---

## Step 5 — Trigger a path-traversal / LFI rule

```bash
curl -s -o /dev/null -w "%{http_code}\n" "http://localhost/?file=../../../../etc/passwd"
```

403 — CRS rule 930100.

---

## Step 6 — Inspect the WAF audit log

```bash
docker exec waf tail -40 /var/log/modsec/modsec_audit.log
```

You will see the matched rule IDs, the request, and the score.

---

## Step 7 — Tune (false-positive triage)

ModSecurity uses an **anomaly score**. The default block threshold is 5. To accept a known-good pattern:

```bash
docker exec waf sh -c "echo 'SecRuleRemoveById 941100' >> /etc/modsecurity.d/exclusions.conf"
docker restart waf
```

In production you tune via test → staging → prod, never prod-first.

---

## Step 8 — Network ACL vs WAF vs Security Group

| Layer | Inspects | Tool used |
|-------|---------|-----------|
| Network ACL (Lab 3) | IP/port | iptables |
| Security Group (Lab 3) | IP/port stateful | iptables -m conntrack |
| WAF (this lab) | HTTP semantics | ModSecurity / CRS |

A WAF sees what a firewall cannot — request bodies, query strings, HTTP headers.

---

## Step 9 — Cleanup

```bash
docker rm -f waf
```

---

## What you learned
- WAFs operate on HTTP semantics, not just IP/port.
- OWASP CRS catches the OWASP Top 10 out of the box.
- Anomaly scoring + tuning is the production workflow.

## Free tools used
- ModSecurity — https://github.com/owasp-modsecurity/ModSecurity
- OWASP Core Rule Set — https://coreruleset.org
- Cloudflare WAF (free tier) — https://www.cloudflare.com/application-services/products/waf
