# Lab 14 — Configuration as Code with Ansible

In this lab you will write a small Ansible playbook that installs and configures Nginx idempotently. Configuration as Code (CaC) is one of the CV0-004 deployment sub-objectives.

Run all commands on the Killercoda Ubuntu Playground:
https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Install Ansible

```bash
apt update && apt install -y ansible curl
ansible --version
```

---

## Step 2 — Inventory (just localhost)

```bash
mkdir -p /tmp/ans && cd /tmp/ans
cat > inventory.ini <<'EOF'
[web]
localhost ansible_connection=local
EOF
```

---

## Step 3 — Write a playbook (YAML)

```bash
cat > site.yml <<'EOF'
---
- name: Configure web server
  hosts: web
  become: true
  vars:
    site_msg: "Configured by Ansible"
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present
        update_cache: true

    - name: Deploy index page
      copy:
        dest: /var/www/html/index.nginx-debian.html
        content: "<h1>{{ site_msg }}</h1>"

    - name: Ensure nginx is running
      service:
        name: nginx
        state: started
        enabled: true
EOF
```

---

## Step 4 — First run (changes everything)

```bash
ansible-playbook -i inventory.ini site.yml
curl -s http://localhost
```

Look at the output: every task is `changed`.

---

## Step 5 — Idempotency test (run again)

```bash
ansible-playbook -i inventory.ini site.yml
```

This time every task is `ok` — no work done. **Idempotency** is the core CaC property.

---

## Step 6 — Detect drift / repeatability

Manually corrupt the page:

```bash
echo "drifted" > /var/www/html/index.nginx-debian.html
ansible-playbook -i inventory.ini site.yml
curl -s http://localhost
```

Ansible re-applies the desired state.

---

## Step 7 — Variables and conditionals

```bash
cat > extra.yml <<'EOF'
---
- hosts: web
  become: true
  vars:
    enable_https: false
  tasks:
    - name: Install certbot only if HTTPS requested
      apt:
        name: certbot
        state: present
      when: enable_https
EOF
ansible-playbook -i inventory.ini extra.yml --check
```

`when:` is a conditional. Re-run with `-e enable_https=true` to flip the path.

---

## Step 8 — Roles preview

```bash
ansible-galaxy init /tmp/ans/roles/myweb
ls /tmp/ans/roles/myweb
```

Roles are reusable bundles — the equivalent of Terraform modules.

---

## Step 9 — Cleanup

```bash
apt remove -y nginx
```

---

## What you learned
- Playbooks are YAML.
- Idempotent tasks: only act if state differs.
- Variables, conditionals, and roles compose larger configurations.

## Free tools used
- Ansible — https://www.ansible.com
- Ansible Galaxy — https://galaxy.ansible.com
- YAML Lint (web) — https://www.yamllint.com
