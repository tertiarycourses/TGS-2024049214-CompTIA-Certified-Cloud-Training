# Lab 35 — Troubleshoot TLS, Cipher & Auth Issues

In this lab you will reproduce and fix the security failures from CV0-004 6.3: **deprecated cipher suites, privilege escalation, unauthorized access, leaked credentials, software vulnerabilities, unauthorized software**.

Run all commands on the Killercoda Ubuntu Playground:
https://killercoda.com/playgrounds/scenario/ubuntu

> **Web tool:** Rehearse the attack/defence scenarios in this lab with the free browser **Cybersecurity Simulator** — https://alfredang.github.io/cybersecuritysimulator/.

---

## Step 1 — Install tools

```bash
apt update && apt install -y openssl curl docker.io git auditd
systemctl start docker
systemctl start auditd
```

---

## Step 2 — Deprecated cipher / TLS version

```bash
docker run -d --name oldssl -p 8443:443 \
  -v /etc/ssl/certs:/certs:ro \
  alpine sh -c "apk add --quiet openssl && openssl req -x509 -newkey rsa:2048 -nodes -keyout /tmp/k -out /tmp/c -subj '/CN=test' -days 1 && openssl s_server -accept 443 -cert /tmp/c -key /tmp/k -tls1 -www" 2>/dev/null

sleep 4

# Try modern client (TLS 1.0 disabled by default)
echo | openssl s_client -connect localhost:8443 -tls1_3 2>&1 | grep -E '(version|alert|verify return)' | head -3

# Negotiate weak version
echo | openssl s_client -connect localhost:8443 -tls1 2>&1 | grep 'Protocol' | head -1

docker rm -f oldssl
```

**Fix:** disable SSLv3, TLS 1.0, TLS 1.1; require TLS 1.2+ with strong AEAD ciphers (AES-GCM, ChaCha20-Poly1305).

---

## Step 3 — Test a public site's cipher suite

```bash
nmap --script ssl-enum-ciphers -p 443 example.com 2>/dev/null | head -40 || \
  echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | grep -E '(Protocol|Cipher)'
```

---

## Step 4 — Privilege escalation detection

```bash
auditctl -w /etc/sudoers -p wa -k sudo-changes
echo '# test' >> /etc/sudoers
ausearch -k sudo-changes 2>/dev/null | tail -5

# Find SUID binaries (potential privesc)
find / -perm -4000 -type f 2>/dev/null | head -10
```

**Fix:** restrict sudoers, audit SUID, run `linpeas`/`Lynis` regularly.

---

## Step 5 — Unauthorized access / brute force

Tail SSH log for failed auth:

```bash
journalctl -u ssh --since "1 hour ago" 2>/dev/null | grep -i "failed\|invalid" | head -5
```

Mitigation: install `fail2ban`:

```bash
apt install -y fail2ban
systemctl start fail2ban
fail2ban-client status sshd 2>/dev/null
```

---

## Step 6 — Leaked credentials in source control

```bash
mkdir -p /tmp/leak && cd /tmp/leak && git init -q
cat > config.py <<'EOF'
AWS_ACCESS_KEY="AKIAIOSFODNN7EXAMPLE"
AWS_SECRET="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
EOF
git add . && git -c user.email=x@x -c user.name=x commit -q -m "oops"

# Detect with gitleaks
docker run --rm -v /tmp/leak:/repo zricethezav/gitleaks:latest detect -s /repo --no-git -v 2>&1 | head -20
```

**Fix:** rotate the leaked key immediately; add a pre-commit `gitleaks` hook; store in Vault (Lab 26).

---

## Step 7 — Software vulnerability + unauthorized software

```bash
# Vulnerable package check (Trivy from Lab 22)
docker run --rm -v /tmp:/scan aquasec/trivy fs --severity CRITICAL /scan 2>&1 | tail -10 || true

# Unauthorized software inventory: list packages added in last 7 days
grep " install " /var/log/dpkg.log 2>/dev/null | tail -10
```

**Fix:** allow-list packages; block unsigned repos; scan in CI (Lab 30).

---

## Step 8 — TLS handshake debugging cheatsheet

| Symptom | Likely cause |
|---------|-------------|
| `unable to get local issuer certificate` | Missing CA bundle |
| `handshake failure` | Cipher mismatch |
| `certificate has expired` | Renew cert (Let's Encrypt) |
| `hostname mismatch` | SAN not matching SNI |
| `ssl3_get_record:wrong version number` | Plain HTTP on TLS port |

---

## Step 9 — Cleanup

```bash
sed -i '/# test/d' /etc/sudoers
rm -rf /tmp/leak
```

---

## What you learned
- Negotiate TLS versions and ciphers from the CLI.
- Detect privesc, brute force, and leaked secrets.
- Common TLS errors and their root causes.

## Free tools used
- OpenSSL — https://www.openssl.org
- testssl.sh — https://testssl.sh
- SSL Labs — https://www.ssllabs.com/ssltest
- gitleaks — https://github.com/gitleaks/gitleaks
- TruffleHog — https://github.com/trufflesecurity/trufflehog
- fail2ban — https://www.fail2ban.org
- auditd (built-in)
