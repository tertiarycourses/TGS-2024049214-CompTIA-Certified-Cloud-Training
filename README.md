# TGS-2024049214 — CompTIA Cloud+ CV0-004 Hands-On Labs

> **Course:** WSQ — CompTIA Certified Cloud+ Training
> **Course Code:** TGS-2024049214
> **Register here:** https://www.tertiarycourses.com.sg/wsq-comptia-cloud-training.html

These are the official hands-on lab exercises for the WSQ CompTIA Certified Cloud+ Training course delivered by [**Tertiary Infotech Academy Pte Ltd**](https://www.tertiarycourses.com.sg/).

A complete set of **36 step-by-step labs** aligned to the CompTIA Cloud+ CV0-004 exam objectives. Every lab runs on the free **Killercoda Ubuntu Playground** (https://killercoda.com/playgrounds/scenario/ubuntu) — no local install, no cloud account, no credit card required.

---

## How to use

1. Open the Killercoda playground in your browser: https://killercoda.com/playgrounds/scenario/ubuntu
2. Pick a lab from the list below and follow the steps in order.
3. Reset the playground between labs that change firewall, container, or kernel state.
4. See [labs/tools.md](labs/tools.md) for every free tool used (with install commands and download links).

---

## Lab catalogue

### Domain 1 — Cloud Architecture (23%)
- [Lab 1 — Cloud Service Models & Shared Responsibility](labs/lab-01-service-models.md)
- [Lab 2 — High Availability with HAProxy & Keepalived](labs/lab-02-ha-haproxy.md)
- [Lab 3 — Cloud Networking with VPC Namespaces](labs/lab-03-vpc-networking.md)
- [Lab 4 — Storage Tiers (Block, Object, File)](labs/lab-04-storage-tiers.md)
- [Lab 5 — Microservices & Service Discovery](labs/lab-05-microservices.md)
- [Lab 6 — Containerization with Docker](labs/lab-06-docker.md)
- [Lab 7 — Virtualization with QEMU/KVM](labs/lab-07-virtualization.md)
- [Lab 8 — Relational vs Non-Relational Databases](labs/lab-08-databases.md)

### Domain 2 — Deployment (19%)
- [Lab 9 — Public, Private & Hybrid Cloud Models](labs/lab-09-deployment-models.md)
- [Lab 10 — Blue-Green Deployment with Nginx](labs/lab-10-blue-green.md)
- [Lab 11 — Canary Deployment with HAProxy](labs/lab-11-canary.md)
- [Lab 12 — Rolling Deployment with Docker Compose](labs/lab-12-rolling.md)
- [Lab 13 — Infrastructure as Code with Terraform](labs/lab-13-terraform.md)
- [Lab 14 — Configuration as Code with Ansible](labs/lab-14-ansible.md)
- [Lab 15 — JSON & YAML Scripting Logic](labs/lab-15-json-yaml.md)

### Domain 3 — Operations (17%)
- [Lab 16 — Observability with Prometheus & Grafana](labs/lab-16-prometheus-grafana.md)
- [Lab 17 — Centralized Logging with the ELK Stack](labs/lab-17-elk-logging.md)
- [Lab 18 — Distributed Tracing with Jaeger](labs/lab-18-jaeger-tracing.md)
- [Lab 19 — Horizontal Auto-Scaling Simulation](labs/lab-19-autoscaling.md)
- [Lab 20 — Backup & Recovery with restic](labs/lab-20-backup-restic.md)
- [Lab 21 — Patching & Lifecycle Management](labs/lab-21-lifecycle.md)

### Domain 4 — Security (19%)
- [Lab 22 — Vulnerability Scanning with Trivy](labs/lab-22-trivy-scan.md)
- [Lab 23 — CIS Benchmark Audit with Lynis](labs/lab-23-lynis-cis.md)
- [Lab 24 — IAM & RBAC with Keycloak](labs/lab-24-keycloak-iam.md)
- [Lab 25 — Bastion Host with SSH Key + MFA](labs/lab-25-bastion-mfa.md)
- [Lab 26 — Secrets Management with HashiCorp Vault](labs/lab-26-vault-secrets.md)
- [Lab 27 — Web Application Firewall with ModSecurity](labs/lab-27-modsec-waf.md)
- [Lab 28 — Detecting Suspicious Activity with Falco](labs/lab-28-falco-detect.md)

### Domain 5 — DevOps Fundamentals (10%)
- [Lab 29 — Git Source Control & Branching](labs/lab-29-git-branching.md)
- [Lab 30 — CI/CD Pipeline with GitHub Actions (act)](labs/lab-30-cicd-act.md)
- [Lab 31 — REST & GraphQL APIs](labs/lab-31-rest-graphql.md)
- [Lab 32 — Container Orchestration with Kubernetes (k3s)](labs/lab-32-k3s.md)

### Domain 6 — Troubleshooting (12%)
- [Lab 33 — Troubleshoot Deployment Issues](labs/lab-33-troubleshoot-deploy.md)
- [Lab 34 — Troubleshoot Cloud Network Issues](labs/lab-34-troubleshoot-network.md)
- [Lab 35 — Troubleshoot TLS, Cipher & Auth Issues](labs/lab-35-troubleshoot-security.md)
- [Lab 36 — Troubleshoot Container & Resource Limits](labs/lab-36-troubleshoot-container.md)

---

## Courseware

Full instructor-led courseware deliverables (all aligned to the 36 labs and the six CV0-004 exam domains) live in [courseware/](courseware/):

- [Slide deck](courseware/CompTIA%20Cloud+%20Slides%20-%20v1.0.pptx) — `CompTIA Cloud+ Slides - v1.0.pptx` (with PDF export)
- [Learner Guide](courseware/Learner%20Guide%20-%20CompTIA%20Cloud+%20-%20v1.0.docx) — `Learner Guide - CompTIA Cloud+ - v1.0.docx` (with PDF export)
- [Lesson Plan](courseware/Lesson%20Plan%20-%20CompTIA%20Cloud+%20-%20v1.0.docx) — `Lesson Plan - CompTIA Cloud+ - v1.0.docx` (with PDF export)

---

## Reference

- [labs/tools.md](labs/tools.md) — Complete list of free tools (Killercoda + external)
- `20241014562-CompTIACloudcv0004ExamObjectives.pdf` — Official exam blueprint

---

## Free tools used

All tooling is **100% free**. The bulk runs inside the disposable Killercoda VM via `apt` or container images. A handful of labs link to free web tools used from your own browser:

- **LocalStack Community** (free local AWS emulator) — Lab 13
- **GitHub Actions / act** (free local workflow runner) — Lab 30
- **JSONLint / YAML Validator** (web) — Lab 15

Full tool list: [labs/tools.md](labs/tools.md).
