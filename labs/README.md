# Hands-On Labs — CompTIA Cloud+ (CV0-004)

36 labs, one folder per lab, mapped to the six CV0-004 exam domains.

## Lab platforms

| Platform | Use it for | Link |
|----------|-----------|------|
| **Killercoda Ubuntu Playground** | The Linux labs — disposable root Ubuntu VM in the browser | https://killercoda.com/playgrounds/scenario/ubuntu |
| **Killercoda Kubernetes Playground** | The Kubernetes labs — a real cluster with `kubectl` | https://killercoda.com/playgrounds/scenario/kubernetes |
| **Docker Desktop** | The container labs, locally on Windows / macOS / Linux | https://www.docker.com/products/docker-desktop/ |

- **Kubernetes playground:** Lab 32
- **Docker Desktop (or Ubuntu playground):** Lab 6, 12, 36
- **Ubuntu playground:** the remaining 32 labs

Each lab states its platform in a **Lab platform** section at the top.
Labs that build config files, manifests or scripts ship them as ready-made files in the lab folder.

See [tools.md](tools.md) for the complete free-tool reference.

## Domain 1 — Cloud Architecture (23% of the exam)

| Lab | Title | Platform | Headline tools |
|-----|-------|----------|----------------|
| 1 | [Cloud Service Models & Shared Responsibility](lab-01-service-models/) | Ubuntu | Docker, curl, jq |
| 2 | [High Availability with HAProxy & Keepalived](lab-02-ha-haproxy/) | Ubuntu | HAProxy, Keepalived, Docker |
| 3 | [Cloud Networking with VPC Namespaces](lab-03-vpc-networking/) | Ubuntu | iproute2 (ip netns), iptables, sysctl |
| 4 | [Storage Tiers (Block, Object, File)](lab-04-storage-tiers/) | Ubuntu | fio, losetup/mkfs.ext4, MinIO + mc |
| 5 | [Microservices & Service Discovery](lab-05-microservices/) | Ubuntu | HashiCorp Consul, Docker bridge network, curl |
| 6 | [Containerization with Docker](lab-06-docker/) | Docker Desktop | Docker, Dockerfile, registry:2 |
| 7 | [Virtualization with QEMU/KVM](lab-07-virtualization/) | Ubuntu | QEMU, qemu-img, libvirt |
| 8 | [Relational vs Non-Relational Databases](lab-08-databases/) | Ubuntu | Docker, PostgreSQL 16 + psql, MongoDB + mongosh |

## Domain 2 — Deployment (19% of the exam)

| Lab | Title | Platform | Headline tools |
|-----|-------|----------|----------------|
| 9 | [Public, Private & Hybrid Cloud Models](lab-09-deployment-models/) | Ubuntu | LocalStack, MinIO + mc, AWS CLI |
| 10 | [Blue-Green Deployment with Nginx](lab-10-blue-green/) | Ubuntu | Nginx, Docker (nginx:alpine), curl |
| 11 | [Canary Deployment with HAProxy](lab-11-canary/) | Ubuntu | HAProxy, Docker (nginx:alpine), curl |
| 12 | [Rolling Deployment with Docker Compose](lab-12-rolling/) | Docker Desktop | Docker Compose, HAProxy, curl |
| 13 | [Infrastructure as Code with Terraform](lab-13-terraform/) | Ubuntu | Terraform, LocalStack, awslocal |
| 14 | [Configuration as Code with Ansible](lab-14-ansible/) | Ubuntu | Ansible, ansible-galaxy, YAML |
| 15 | [JSON & YAML Scripting Logic](lab-15-json-yaml/) | Ubuntu | jq, yq, diff |

## Domain 3 — Operations (17% of the exam)

| Lab | Title | Platform | Headline tools |
|-----|-------|----------|----------------|
| 16 | [Observability with Prometheus & Grafana](lab-16-prometheus-grafana/) | Ubuntu | Prometheus, Grafana, node-exporter |
| 17 | [Centralized Logging with the ELK Stack](lab-17-elk-logging/) | Ubuntu | Elasticsearch, Logstash, Kibana |
| 18 | [Distributed Tracing with Jaeger](lab-18-jaeger-tracing/) | Ubuntu | Jaeger, OpenTelemetry Python SDK, Docker |
| 19 | [Horizontal Auto-Scaling Simulation](lab-19-autoscaling/) | Ubuntu | Docker Compose, stress-ng, cron |
| 20 | [Backup & Recovery with restic](lab-20-backup-restic/) | Ubuntu | restic, MinIO, Docker |
| 21 | [Patching & Lifecycle Management](lab-21-lifecycle/) | Ubuntu | apt, unattended-upgrades, Docker |

## Domain 4 — Security (19% of the exam)

| Lab | Title | Platform | Headline tools |
|-----|-------|----------|----------------|
| 22 | [Vulnerability Scanning with Trivy](lab-22-trivy-scan/) | Ubuntu | Trivy, Docker, sample Terraform |
| 23 | [CIS Benchmark Audit with Lynis](lab-23-lynis-cis/) | Ubuntu | Lynis, chmod, sysctl |
| 24 | [IAM & RBAC with Keycloak](lab-24-keycloak-iam/) | Ubuntu | Keycloak, Docker, curl |
| 25 | [Bastion Host with SSH Key + MFA](lab-25-bastion-mfa/) | Ubuntu | OpenSSH, ssh-keygen, Google Authenticator (PAM) |
| 26 | [Secrets Management with HashiCorp Vault](lab-26-vault-secrets/) | Ubuntu | HashiCorp Vault, Docker, PostgreSQL |
| 27 | [Web Application Firewall with ModSecurity](lab-27-modsec-waf/) | Ubuntu | Docker (owasp/modsecurity-crs), Nginx, OWASP CRS |
| 28 | [Detecting Suspicious Activity with Falco](lab-28-falco-detect/) | Ubuntu | Falco (eBPF), Docker, falcosidekick |

## Domain 5 — DevOps Fundamentals (10% of the exam)

| Lab | Title | Platform | Headline tools |
|-----|-------|----------|----------------|
| 29 | [Git Source Control & Branching](lab-29-git-branching/) | Ubuntu | git, Gitea (self-hosted), curl |
| 30 | [CI/CD Pipeline with GitHub Actions (act)](lab-30-cicd-act/) | Ubuntu | act (nektos/act), Docker, git |
| 31 | [REST & GraphQL APIs](lab-31-rest-graphql/) | Ubuntu | curl, jq, GraphQL Yoga |
| 32 | [Container Orchestration with Kubernetes (k3s)](lab-32-k3s/) | Kubernetes | k3s, kubectl, YAML manifests |

## Domain 6 — Troubleshooting (12% of the exam)

| Lab | Title | Platform | Headline tools |
|-----|-------|----------|----------------|
| 33 | [Troubleshoot Deployment Issues](lab-33-troubleshoot-deploy/) | Ubuntu | Docker, curl, jq |
| 34 | [Troubleshoot Cloud Network Issues](lab-34-troubleshoot-network/) | Ubuntu | dig/nslookup, ip, iptables |
| 35 | [Troubleshoot TLS, Cipher & Auth Issues](lab-35-troubleshoot-security/) | Ubuntu | openssl, nmap, auditd |
| 36 | [Troubleshoot Container & Resource Limits](lab-36-troubleshoot-container/) | Docker Desktop | docker (inspect/stats/logs), a triage.sh script, k9s/ctop |
