# Lab 25 — Bastion Host with SSH Key + MFA

In this lab you will configure SSH key-based authentication, add **Google Authenticator TOTP** as a second factor, and route through a **bastion** (jump host) — the canonical secure-access pattern for cloud VMs.

Run all commands on the Killercoda Ubuntu Playground:
https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Install OpenSSH server and Google Authenticator

```bash
apt update && apt install -y openssh-server libpam-google-authenticator
systemctl start ssh
ss -ltn | grep :22
```

---

## Step 2 — Generate SSH key (no password)

```bash
ssh-keygen -t ed25519 -N "" -f /root/.ssh/id_ed25519
cat /root/.ssh/id_ed25519.pub >> /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
```

Test:

```bash
ssh -o StrictHostKeyChecking=no localhost "echo SSH key auth OK"
```

---

## Step 3 — Disable password auth, allow only keys

```bash
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config
echo 'AuthenticationMethods publickey,keyboard-interactive' >> /etc/ssh/sshd_config
```

---

## Step 4 — Set up TOTP MFA for root

```bash
google-authenticator -t -d -f -r 3 -R 30 -W -q -s /root/.google_authenticator
ls -l /root/.google_authenticator
head -1 /root/.google_authenticator
```

The first line is the **TOTP seed** — scan that as a QR with Google Authenticator / Authy / FreeOTP on your phone.

Wire it into PAM:

```bash
sed -i '1a auth required pam_google_authenticator.so' /etc/pam.d/sshd
systemctl restart ssh
```

Now SSH requires **key + 6-digit TOTP**.

---

## Step 5 — Create a "bastion" architecture

Run a private app behind a network namespace; the bastion is the only way in.

```bash
docker run -d --name app nginx:alpine
APP_IP=$(docker inspect -f '{{(index .NetworkSettings.Networks "bridge").IPAddress}}' app)
echo "App IP (private): $APP_IP"

# Bastion = your Killercoda root SSH on port 22
# Client jump:
ssh -J root@localhost root@$APP_IP "echo 'reached private app via bastion' " 2>&1 || true
```

The pattern in production: **internet → bastion (only host with public IP) → private subnet hosts**.

---

## Step 6 — Restrict who can reach the bastion

```bash
ufw enable >/dev/null 2>&1 || apt install -y ufw
ufw allow from 10.0.0.0/8 to any port 22 proto tcp
ufw status verbose
```

Lock the bastion to corporate CIDRs only.

---

## Step 7 — Audit trail

```bash
journalctl -u ssh -n 20 --no-pager
last -n 5
```

`last`/`journalctl` give you the **audit trail** required by SOC2 / ISO 27001.

---

## Step 8 — Cleanup

```bash
docker rm -f app
sed -i '/AuthenticationMethods/d' /etc/ssh/sshd_config
sed -i '/pam_google_authenticator/d' /etc/pam.d/sshd
systemctl restart ssh
ufw disable 2>/dev/null
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
ss -ltn | grep :22
ssh -o StrictHostKeyChecking=no localhost "echo SSH key auth OK"
grep -E '^(PasswordAuthentication|PubkeyAuthentication|AuthenticationMethods)' /etc/ssh/sshd_config
ls -l /root/.google_authenticator
grep pam_google_authenticator /etc/pam.d/sshd
ufw status verbose
```

**Expected:** Run this before Step 8. `ss` shows sshd LISTENing on port 22; the key-based SSH prints `SSH key auth OK` with no password prompt; the sshd config reads `PasswordAuthentication no`, `PubkeyAuthentication yes` and `AuthenticationMethods publickey,keyboard-interactive`; the `/root/.google_authenticator` TOTP seed file exists with `-r--------` permissions; PAM includes the `pam_google_authenticator.so` line; and `ufw status` shows port 22 allowed only from `10.0.0.0/8`.

---

## What you learned
- SSH key auth, MFA via TOTP, and bastion jump-hosts.
- AuthenticationMethods chains factors.
- Audit trails come for free with systemd-journald.

## Free tools used
- OpenSSH — https://www.openssh.com
- Google Authenticator PAM — https://github.com/google/google-authenticator-libpam
- FreeOTP (mobile, free) — https://freeotp.github.io
- Authy / Microsoft Authenticator — free mobile apps
