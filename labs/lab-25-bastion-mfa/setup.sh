#!/usr/bin/env bash
# Lab 25 — Bastion Host with SSH Key + MFA
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# Builds Steps 1-6: sshd, the ed25519 key, key-only + TOTP MFA config, the private app
# behind the bastion, and the ufw source restriction.
set -euo pipefail

echo "==> Step 1: Installing OpenSSH server and Google Authenticator"
apt update && apt install -y openssh-server libpam-google-authenticator
systemctl start ssh
ss -ltn | grep :22

echo "==> Step 2: Generating the SSH key (no passphrase)"
ssh-keygen -t ed25519 -N "" -f /root/.ssh/id_ed25519
cat /root/.ssh/id_ed25519.pub >> /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

ssh -o StrictHostKeyChecking=no localhost "echo SSH key auth OK"

echo "==> Step 3: Disabling password auth, allowing only keys"
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config
echo 'AuthenticationMethods publickey,keyboard-interactive' >> /etc/ssh/sshd_config

echo "==> Step 4: Setting up TOTP MFA for root"
google-authenticator -t -d -f -r 3 -R 30 -W -q -s /root/.google_authenticator
ls -l /root/.google_authenticator
head -1 /root/.google_authenticator

echo "==> Step 4: Wiring the TOTP module into PAM"
sed -i '1a auth required pam_google_authenticator.so' /etc/pam.d/sshd
systemctl restart ssh

echo "==> Step 5: Creating the bastion architecture (private app behind the jump host)"
docker run -d --name app nginx:alpine
APP_IP=$(docker inspect -f '{{(index .NetworkSettings.Networks "bridge").IPAddress}}' app)
echo "App IP (private): $APP_IP"

echo "==> Step 6: Restricting who can reach the bastion"
ufw enable >/dev/null 2>&1 || apt install -y ufw
ufw allow from 10.0.0.0/8 to any port 22 proto tcp
ufw status verbose

echo
echo "You should now see: sshd LISTENing on :22, key-only auth working with no password"
echo "prompt, /root/.google_authenticator holding the TOTP seed (scan line 1 as a QR),"
echo "pam_google_authenticator.so in /etc/pam.d/sshd, the private 'app' container running,"
echo "and ufw allowing :22 only from 10.0.0.0/8."
echo "Next: try the Step 5 jump ('ssh -J root@localhost root@\$APP_IP') and read the Step 7"
echo "audit trail, then 'bash cleanup.sh'."
