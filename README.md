<div align="center">

# ☁️ WSQ CompTIA Certified Cloud+ Training

**Build, deploy, secure and troubleshoot the cloud — 36 hands-on labs mapped to every CV0-004 exam objective.**

[![Register](https://img.shields.io/badge/📝_Register-Tertiary_Infotech-1F6FEB?style=for-the-badge)](https://www.tertiarycourses.com.sg/wsq-comptia-certified-cloud-training.html)
[![Course Code](https://img.shields.io/badge/WSQ-TGS-2024049214-10B981?style=flat-square)](https://www.tertiarycourses.com.sg/wsq-comptia-certified-cloud-training.html)
![Exam](https://img.shields.io/badge/Exam-CompTIA%20Cloud%2B%20CV0--004-E21D2E?style=flat-square)
![Duration](https://img.shields.io/badge/Duration-2%20Days%20·%2016%20Hours-7C3AED?style=flat-square)
![Labs](https://img.shields.io/badge/Hands--On%20Labs-36-F59E0B?style=flat-square)
![TSC](https://img.shields.io/badge/TSC-ICT--DIT--5020--1.1-555?style=flat-square)
![Assessment](https://img.shields.io/badge/Assessment-WA%20%2B%20PP-1F6FEB?style=flat-square)
![Funding](https://img.shields.io/badge/SkillsFuture-Claimable-10B981?style=flat-square)

**[📝 Register for this course →](https://www.tertiarycourses.com.sg/wsq-comptia-certified-cloud-training.html)**

</div>

---

## About This Course

This WSQ course takes you from cloud fundamentals to running production-grade cloud systems, and prepares you for the **CompTIA Cloud+ (CV0-004)** certification exam. You will build every concept yourself — virtual networks, containers, Kubernetes, Infrastructure as Code, observability stacks, IAM, WAFs and CI/CD pipelines — then break them and fix them.

It is designed for systems administrators, cloud engineers, DevOps practitioners and IT professionals with roughly 2–3 years of experience who want a vendor-neutral cloud credential. Every one of the **36 labs** runs free in the browser on the [Killercoda Ubuntu Playground](https://killercoda.com/playgrounds/scenario/ubuntu) — no cloud account, no install, no credit card.

---

## Learning Outcomes

| # | On completion of this course you will be able to |
|---|---|
| **LO1** | Explain cloud architecture, service models (IaaS/PaaS/SaaS/FaaS) and the shared responsibility model, and design highly-available, well-networked cloud solutions. |
| **LO2** | Deploy cloud workloads using containers, virtualization, Infrastructure as Code and modern release strategies (blue-green, canary, rolling). |
| **LO3** | Operate cloud systems with observability, logging, tracing, auto-scaling, backup/recovery and lifecycle management. |
| **LO4** | Secure a cloud environment with vulnerability management, hardening, IAM/RBAC, secrets management, WAF and runtime threat detection. |
| **LO5** | Apply DevOps fundamentals — source control, CI/CD, APIs and container orchestration. |
| **LO6** | Troubleshoot common cloud deployment, network, security and container issues methodically. |

---

## Course Topics & Labs

The course follows the six CV0-004 exam domains. Each lab lives in **its own folder** with a complete step-by-step guide.

### Domain 1 — Cloud Architecture · 23% of the exam

Cloud concepts, service and deployment models, the shared responsibility model, high availability, networking (VPC), storage tiers, virtualization, databases and cloud-native / microservices design.

| Lab | Title | Headline tools |
|-----|-------|----------------|
| **1** | [Cloud Service Models & Shared Responsibility](labs/lab-01-service-models/) | Docker, curl, jq |
| **2** | [High Availability with HAProxy & Keepalived](labs/lab-02-ha-haproxy/) | HAProxy, Keepalived, Docker |
| **3** | [Cloud Networking with VPC Namespaces](labs/lab-03-vpc-networking/) | iproute2 (ip netns), iptables, sysctl |
| **4** | [Storage Tiers (Block, Object, File)](labs/lab-04-storage-tiers/) | fio, losetup/mkfs.ext4, MinIO + mc |
| **5** | [Microservices & Service Discovery](labs/lab-05-microservices/) | HashiCorp Consul, Docker bridge network, curl |
| **6** | [Containerization with Docker](labs/lab-06-docker/) | Docker, Dockerfile, registry:2 |
| **7** | [Virtualization with QEMU/KVM](labs/lab-07-virtualization/) | QEMU, qemu-img, libvirt |
| **8** | [Relational vs Non-Relational Databases](labs/lab-08-databases/) | Docker, PostgreSQL 16 + psql, MongoDB + mongosh |

### Domain 2 — Deployment · 19% of the exam

Provisioning and configuring cloud resources: deployment models, zero-downtime release strategies (blue-green, canary, rolling), Infrastructure as Code, Configuration as Code and scripting logic.

| Lab | Title | Headline tools |
|-----|-------|----------------|
| **9** | [Public, Private & Hybrid Cloud Models](labs/lab-09-deployment-models/) | LocalStack, MinIO + mc, AWS CLI |
| **10** | [Blue-Green Deployment with Nginx](labs/lab-10-blue-green/) | Nginx, Docker (nginx:alpine), curl |
| **11** | [Canary Deployment with HAProxy](labs/lab-11-canary/) | HAProxy, Docker (nginx:alpine), curl |
| **12** | [Rolling Deployment with Docker Compose](labs/lab-12-rolling/) | Docker Compose, HAProxy, curl |
| **13** | [Infrastructure as Code with Terraform](labs/lab-13-terraform/) | Terraform, LocalStack, awslocal |
| **14** | [Configuration as Code with Ansible](labs/lab-14-ansible/) | Ansible, ansible-galaxy, YAML |
| **15** | [JSON & YAML Scripting Logic](labs/lab-15-json-yaml/) | jq, yq, diff |

### Domain 3 — Operations · 17% of the exam

Running cloud systems day-to-day: observability (metrics, logs, traces), alerting, auto-scaling, backup & disaster recovery, and patching / lifecycle management.

| Lab | Title | Headline tools |
|-----|-------|----------------|
| **16** | [Observability with Prometheus & Grafana](labs/lab-16-prometheus-grafana/) | Prometheus, Grafana, node-exporter |
| **17** | [Centralized Logging with the ELK Stack](labs/lab-17-elk-logging/) | Elasticsearch, Logstash, Kibana |
| **18** | [Distributed Tracing with Jaeger](labs/lab-18-jaeger-tracing/) | Jaeger, OpenTelemetry Python SDK, Docker |
| **19** | [Horizontal Auto-Scaling Simulation](labs/lab-19-autoscaling/) | Docker Compose, stress-ng, cron |
| **20** | [Backup & Recovery with restic](labs/lab-20-backup-restic/) | restic, MinIO, Docker |
| **21** | [Patching & Lifecycle Management](labs/lab-21-lifecycle/) | apt, unattended-upgrades, Docker |

### Domain 4 — Security · 19% of the exam

Securing the cloud: vulnerability management, CIS hardening, IAM & RBAC, secure access (bastion + MFA), secrets management, web application firewalls and runtime threat detection.

| Lab | Title | Headline tools |
|-----|-------|----------------|
| **22** | [Vulnerability Scanning with Trivy](labs/lab-22-trivy-scan/) | Trivy, Docker, sample Terraform |
| **23** | [CIS Benchmark Audit with Lynis](labs/lab-23-lynis-cis/) | Lynis, chmod, sysctl |
| **24** | [IAM & RBAC with Keycloak](labs/lab-24-keycloak-iam/) | Keycloak, Docker, curl |
| **25** | [Bastion Host with SSH Key + MFA](labs/lab-25-bastion-mfa/) | OpenSSH, ssh-keygen, Google Authenticator (PAM) |
| **26** | [Secrets Management with HashiCorp Vault](labs/lab-26-vault-secrets/) | HashiCorp Vault, Docker, PostgreSQL |
| **27** | [Web Application Firewall with ModSecurity](labs/lab-27-modsec-waf/) | Docker (owasp/modsecurity-crs), Nginx, OWASP CRS |
| **28** | [Detecting Suspicious Activity with Falco](labs/lab-28-falco-detect/) | Falco (eBPF), Docker, falcosidekick |

### Domain 5 — DevOps Fundamentals · 10% of the exam

Source control and branching, CI/CD pipelines, web-service APIs (REST / GraphQL) and container orchestration with Kubernetes.

| Lab | Title | Headline tools |
|-----|-------|----------------|
| **29** | [Git Source Control & Branching](labs/lab-29-git-branching/) | git, Gitea (self-hosted), curl |
| **30** | [CI/CD Pipeline with GitHub Actions (act)](labs/lab-30-cicd-act/) | act (nektos/act), Docker, git |
| **31** | [REST & GraphQL APIs](labs/lab-31-rest-graphql/) | curl, jq, GraphQL Yoga |
| **32** | [Container Orchestration with Kubernetes (k3s)](labs/lab-32-k3s/) | k3s, kubectl, YAML manifests |

### Domain 6 — Troubleshooting · 12% of the exam

Methodically diagnosing and fixing deployment, network, security and container / resource issues using a repeatable triage workflow.

| Lab | Title | Headline tools |
|-----|-------|----------------|
| **33** | [Troubleshoot Deployment Issues](labs/lab-33-troubleshoot-deploy/) | Docker, curl, jq |
| **34** | [Troubleshoot Cloud Network Issues](labs/lab-34-troubleshoot-network/) | dig/nslookup, ip, iptables |
| **35** | [Troubleshoot TLS, Cipher & Auth Issues](labs/lab-35-troubleshoot-security/) | openssl, nmap, auditd |
| **36** | [Troubleshoot Container & Resource Limits](labs/lab-36-troubleshoot-container/) | docker (inspect/stats/logs), a triage.sh script, k9s/ctop |

---

## Tools

### Free browser tools — nothing to install

| Tool | What you use it for |
|------|--------------------|
| [Killercoda Ubuntu Playground](https://killercoda.com/playgrounds/scenario/ubuntu) | Disposable root Ubuntu VM — runs every lab |
| [IP Calculator](https://alfredang.github.io/ipcalculator/) | Subnet/CIDR planning for the VPC and networking labs |
| [PCAP Analyzer](https://alfredang.github.io/pcapanalyzer/) | Inspect packet captures from the network troubleshooting lab |
| [Regex Generator](https://alfredang.github.io/regexgenerator/) | Build grok/regex patterns for the centralized logging lab |
| [Cybersecurity Simulator](https://alfredang.github.io/cybersecuritysimulator/) | Practise attack/defence scenarios from the security labs |

### Installed in the lab VM

Docker · Docker Compose · Kubernetes (k3s) · QEMU/KVM · Terraform · Ansible · HAProxy · Nginx · Keepalived · Prometheus · Grafana · ELK · Jaeger · restic · MinIO · Trivy · Lynis · Keycloak · HashiCorp Vault · ModSecurity + OWASP CRS · Falco · Git + Gitea · act · PostgreSQL · MongoDB · Redis · Consul

The complete free-tool reference, with install commands and links, is in **[labs/tools.md](labs/tools.md)**.

---

## Repository Structure

```
.
├── labs/                     # 36 hands-on labs — one folder per lab
│   ├── lab-01-service-models/
│   │   └── README.md         # step-by-step lab guide
│   ├── …
│   ├── README.md             # lab index by exam domain
│   └── tools.md              # complete free-tool reference
└── courseware/               # trainer & learner deliverables
    ├── CompTIA Cloud+ Slides - v2.0.pptx / .pdf
    ├── Learner Guide - CompTIA Cloud+ - v2.0.docx / .pdf
    ├── Lesson Plan - CompTIA Cloud+ - v2.0.docx / .pdf
    └── archive/              # superseded versions
```

> **Note:** the confidential `assessment/` folder (question papers and answer keys) is **not** in this repository. Assessment materials are distributed to trainers via Google Drive and the LMS only.

---

## Course Details

| | |
|---|---|
| **Course title** | WSQ CompTIA Certified Cloud+ Training |
| **WSQ course code** | TGS-2024049214 |
| **TSC** | Cloud Computing (ICT-DIT-5020-1.1) |
| **Duration** | 2 days · 16 hours |
| **Level** | Intermediate — 2–3 years systems/cloud administration recommended |
| **Assessment** | Written Assessment (WA) 1 hr + Practical Performance (PP) 90 min |
| **Mode** | Classroom / synchronous e-learning · 100% hands-on |
| **Certification target** | CompTIA Cloud+ CV0-004 — Maximum of 90, 90 minutes, pass 750 (on a scale of 100–900) |
| **Training provider** | Tertiary Infotech Academy Pte Ltd · UEN 201200696W |

### Funding

This is a **WSQ-funded** course. Singapore Citizens, PRs and eligible companies can claim SkillsFuture / SSG funding subject to prevailing rates and eligibility. A minimum **75% attendance** and a **Competent (C)** grade in both assessments are required. See the [course page](https://www.tertiarycourses.com.sg/wsq-comptia-certified-cloud-training.html) for current fees, funding tiers and dates.

---

## Building the Courseware

All artifacts are generated from a single source of truth, so the deck, Learner Guide, Lesson Plan and labs can never drift apart:

```bash
SK=.claude/skills/cloudplus-courseware-build
python3 $SK/build_ppt.py             # slide deck  (PPTX + PDF)
python3 $SK/build_learner_guide.py   # Learner Guide (DOCX + PDF + Markdown mirror)
python3 $SK/build_lesson_plan.py     # Lesson Plan  (DOCX + PDF)
```

Course content lives in `course_data.py` and `data_domain1.py` … `data_domain6.py`; the labs are the Markdown files under `labs/`, embedded verbatim into the Learner Guide.

---

## Contact

- **Register / course page:** [www.tertiarycourses.com.sg/wsq-comptia-certified-cloud-training.html](https://www.tertiarycourses.com.sg/wsq-comptia-certified-cloud-training.html)
- **Email:** enquiry@tertiaryinfotech.com
- **Tel:** +65 6100 0613
- **LMS / TMS:** https://lms-tms.tertiaryinfotech.com/
- **Website:** [www.tertiarycourses.com.sg](https://www.tertiarycourses.com.sg)

---

<div align="center">

### Ready to get cloud certified?

**[📝 Register for WSQ CompTIA Certified Cloud+ Training →](https://www.tertiarycourses.com.sg/wsq-comptia-certified-cloud-training.html)**

© 2026 Tertiary Infotech Academy Pte Ltd · UEN 201200696W

</div>
