# Free Tools Reference — CompTIA Cloud+ CV0-004 Labs

Every tool listed here is **100% free** (open-source, freeware, or free tier with no time limit).

Two categories:

1. **Inside Killercoda** — installed in the disposable Ubuntu VM via `apt` or pulled as a Docker image. Nothing touches your own machine.
2. **External / Standalone** — downloaded onto your own PC/laptop, or used in a browser. Useful when you're offline, on a school PC, or want a GUI.

Killercoda playground (free, no signup): https://killercoda.com/playgrounds/scenario/ubuntu

---

## Section A — Tools installed inside the Killercoda Ubuntu VM

### A1. Container & virtualization
| Tool | Install | Purpose | Lab |
|------|---------|---------|-----|
| `docker.io` | `apt install docker.io` | Container runtime | 1, 2, 4–6, 8–14, 16–22, 24, 26–34, 36 |
| `docker-compose-v2` | `apt install docker-compose-v2` | Multi-container orchestration | 6, 12, 19 |
| `qemu-system-x86` | `apt install qemu-system-x86` | Type-2 hypervisor | 7 |
| `libvirt-daemon-system` | `apt install libvirt-daemon-system` | Virtualization API | 7 |
| `qemu-utils` | `apt install qemu-utils` | qcow2 image tools | 7 |
| k3s | `curl -sfL https://get.k3s.io | sh -` | Lightweight Kubernetes | 32 |

### A2. Networking & VPC
| Tool | Install | Purpose | Lab |
|------|---------|---------|-----|
| `iproute2` (ip, ss) | pre-installed | Namespaces, routes, sockets | 3, 33, 34 |
| `iptables` | pre-installed | NAT, ACL, security groups | 3, 33, 34 |
| `haproxy` | `apt install haproxy` | L4/L7 load balancer | 2, 11, 12 |
| `keepalived` | `apt install keepalived` | VRRP floating IP | 2 |
| `nginx` | `apt install nginx` | Reverse proxy, blue-green | 10, 14 |
| `wireguard-tools` | `apt install wireguard-tools` | Site-to-site VPN | 9 |
| `dnsutils` (dig) | `apt install dnsutils` | DNS query | 5, 34 |
| `chrony` | `apt install chrony` | NTP sync | 34 |
| `tcpdump` | `apt install tcpdump` | Packet capture | 34 |

### A3. Storage
| Tool | Install | Purpose | Lab |
|------|---------|---------|-----|
| `nfs-kernel-server` | `apt install nfs-kernel-server` | File share | 4 |
| `fio` | `apt install fio` | IOPS / throughput test | 4 |
| MinIO (Docker) | `docker run minio/minio` | S3-compatible object store | 4, 9, 20 |
| restic | `apt install restic` | Encrypted dedup backup | 20 |

### A4. Databases
| Tool | Install | Purpose | Lab |
|------|---------|---------|-----|
| `postgresql-client` | `apt install postgresql-client` | psql CLI | 1, 8, 26 |
| Postgres (Docker) | `docker run postgres:16` | Relational DB | 1, 8, 26, 33 |
| MongoDB (Docker) | `docker run mongo:7` | Non-relational DB | 8 |
| Redis (Docker) | `docker run redis:7-alpine` | Cache / pub-sub | 6, 31 |

### A5. IaC, CaC, source control
| Tool | Install | Purpose | Lab |
|------|---------|---------|-----|
| Terraform | wget binary | IaC | 13 |
| Ansible | `apt install ansible` | Configuration as code | 14 |
| `git` | `apt install git` | Version control | 13, 19, 29, 35 |
| Gitea (Docker) | `docker run gitea/gitea` | Self-hosted Git server | 29 |
| `act` | install script | GitHub Actions runner local | 30 |

### A6. Observability
| Tool | Install | Purpose | Lab |
|------|---------|---------|-----|
| Prometheus (Docker) | `docker run prom/prometheus` | Metrics + alerting | 16 |
| node-exporter (Docker) | `docker run prom/node-exporter` | Host metrics | 16 |
| Grafana (Docker) | `docker run grafana/grafana` | Dashboards | 16 |
| Elasticsearch / Kibana / Logstash | Docker images | Centralized logging | 17 |
| Jaeger (Docker) | `docker run jaegertracing/all-in-one` | Distributed tracing | 18 |
| `stress-ng` | `apt install stress-ng` | Load generator | 16, 19 |

### A7. Security
| Tool | Install | Purpose | Lab |
|------|---------|---------|-----|
| Trivy | apt repo | Image / FS / IaC scanner | 22, 30, 35 |
| Lynis | `apt install lynis` | CIS audit | 23 |
| Keycloak (Docker) | `docker run quay.io/keycloak/keycloak` | IAM / OIDC / SAML | 24 |
| Google Authenticator PAM | `apt install libpam-google-authenticator` | TOTP MFA | 25 |
| Vault (Docker) | `docker run hashicorp/vault` | Secrets manager | 26 |
| ModSecurity + CRS (Docker) | `docker run owasp/modsecurity-crs` | WAF | 27 |
| Falco | apt repo | Runtime detection | 28 |
| auditd | `apt install auditd` | Linux audit | 35 |
| fail2ban | `apt install fail2ban` | SSH brute-force defence | 35 |
| gitleaks (Docker) | `docker run zricethezav/gitleaks` | Secret-scanning | 35 |
| `openssl` | pre-installed | TLS / certs | 35 |
| `nmap` | `apt install nmap` | Cipher enumeration, port scan | 35 |

### A8. APIs & utilities
| Tool | Install | Purpose | Lab |
|------|---------|---------|-----|
| `curl` | pre-installed | HTTP / API client | every lab |
| `jq` | `apt install jq` | JSON parser | 5, 15, 24, 26, 31 |
| `yq` | `pip install yq` | YAML parser | 15 |
| `awscli` | `apt install awscli` | AWS / LocalStack CLI | 9, 13 |
| `websocat` | `apt install websocat` | WebSocket CLI | 31 |
| `unattended-upgrades` | `apt install unattended-upgrades` | Auto-patch | 21 |

---

## Section B — External / Standalone Free Tools (download or browser)

### B1. Cloud emulators / sandboxes
| Tool | Type | Link |
|------|------|------|
| **LocalStack Community** ⭐ used in Lab 13 | Local AWS | https://www.localstack.cloud |
| MinIO | S3 server | https://min.io |
| MockAPI | Web mock API | https://mockapi.io |
| AWS Free Tier | Cloud account | https://aws.amazon.com/free |
| Azure Free Account | Cloud account | https://azure.microsoft.com/free |
| Google Cloud Free Tier | Cloud account | https://cloud.google.com/free |
| Oracle Always Free | Cloud account | https://www.oracle.com/cloud/free |

### B2. Browser playgrounds (Killercoda alternatives)
| Service | What you get | Link |
|---------|-------------|------|
| **Killercoda Ubuntu Playground** ⭐ used everywhere | Root Ubuntu shell | https://killercoda.com/playgrounds/scenario/ubuntu |
| Killercoda Kubernetes | k8s cluster in browser | https://killercoda.com/playgrounds/scenario/kubernetes |
| Killercoda Docker | Docker in browser | https://killercoda.com/playgrounds/scenario/docker |
| Play with Docker | Docker VM | https://labs.play-with-docker.com |
| Play with Kubernetes | k8s cluster | https://labs.play-with-k8s.com |
| Replit | Linux + code | https://replit.com |

### B3. JSON / YAML validators (Lab 15)
| Tool | Type | Link |
|------|------|------|
| JSONLint | Web | https://jsonlint.com |
| YAML Lint | Web | https://www.yamllint.com |
| JSON Schema Validator | Web | https://www.jsonschemavalidator.net |
| jq Play | Web jq REPL | https://jqplay.org |

### B4. IaC / DevOps GUIs
| Tool | Type | Link |
|------|------|------|
| Terraform | CLI | https://developer.hashicorp.com/terraform |
| OpenTofu | CLI (fork) | https://opentofu.org |
| Pulumi (free tier) | IaC in code | https://www.pulumi.com |
| Ansible / Galaxy | CLI / hub | https://galaxy.ansible.com |
| GitHub Actions | SaaS CI | https://github.com/features/actions |
| GitLab CI | SaaS / self-hosted | https://about.gitlab.com |
| Jenkins | Self-hosted | https://www.jenkins.io |
| Drone CI | Self-hosted | https://www.drone.io |

### B5. Container & K8s tools
| Tool | Type | Link |
|------|------|------|
| Docker Desktop | Free for personal/SMB | https://www.docker.com/products/docker-desktop |
| Podman Desktop | Open-source | https://podman-desktop.io |
| Rancher Desktop | Free K8s | https://rancherdesktop.io |
| Lens Desktop | K8s GUI | https://k8slens.dev |
| k9s | K8s TUI | https://k9scli.io |
| kubectx / kubens | Context switcher | https://github.com/ahmetb/kubectx |
| Minikube | Local K8s | https://minikube.sigs.k8s.io |
| Kind | K8s in Docker | https://kind.sigs.k8s.io |

### B6. Observability (cloud / SaaS free tiers)
| Tool | Type | Link |
|------|------|------|
| Grafana Cloud Free | SaaS | https://grafana.com/products/cloud |
| Prometheus | OSS | https://prometheus.io |
| Loki | OSS logs | https://grafana.com/oss/loki |
| Jaeger | OSS traces | https://www.jaegertracing.io |
| Zipkin | OSS traces | https://zipkin.io |
| OpenTelemetry | Standard | https://opentelemetry.io |
| New Relic Free Forever | SaaS | https://newrelic.com/pricing |
| Datadog Free Tier (5 hosts) | SaaS | https://www.datadoghq.com |

### B7. Security tools
| Tool | Type | Link |
|------|------|------|
| Trivy | OSS scanner | https://aquasecurity.github.io/trivy |
| Grype | OSS scanner | https://github.com/anchore/grype |
| OpenVAS / Greenbone CE | OSS vuln scanner | https://www.greenbone.net |
| Prowler | Cloud audit | https://github.com/prowler-cloud/prowler |
| ScoutSuite | Cloud audit | https://github.com/nccgroup/ScoutSuite |
| kube-bench | CIS K8s | https://github.com/aquasecurity/kube-bench |
| Docker Bench Security | CIS Docker | https://github.com/docker/docker-bench-security |
| CIS Benchmarks (PDF) | Standards | https://www.cisecurity.org/cis-benchmarks |
| OWASP Top 10 | Reference | https://owasp.org/Top10 |
| OWASP CRS | WAF rules | https://coreruleset.org |
| Falco | Runtime detection | https://falco.org |
| Wazuh | OSS SIEM | https://wazuh.com |
| SSL Labs Server Test | Web | https://www.ssllabs.com/ssltest |
| testssl.sh | CLI | https://testssl.sh |
| jwt.io | JWT decoder | https://jwt.io |
| gitleaks | Secret scan | https://github.com/gitleaks/gitleaks |
| TruffleHog | Secret scan | https://github.com/trufflesecurity/trufflehog |

### B8. Identity / MFA apps (mobile)
| Tool | Type | Link |
|------|------|------|
| Google Authenticator | Free | Play / App Store |
| Microsoft Authenticator | Free | Play / App Store |
| FreeOTP | OSS | https://freeotp.github.io |
| Authy | Free | https://authy.com |
| YubiKey (hardware) | Paid | https://www.yubico.com |

### B9. CVE / vulnerability databases
| Site | Use | Link |
|------|-----|------|
| NVD | Authoritative CVE | https://nvd.nist.gov |
| CVE.org | CVE listing | https://www.cve.org |
| MITRE ATT&CK | TTPs | https://attack.mitre.org |
| Exploit-DB | PoC | https://www.exploit-db.com |
| endoflife.date | EoL tracking | https://endoflife.date |

### B10. API tools
| Tool | Type | Link |
|------|------|------|
| Postman Free | GUI | https://www.postman.com |
| Hoppscotch | Web / OSS | https://hoppscotch.io |
| Insomnia | GUI | https://insomnia.rest |
| HTTPie | CLI | https://httpie.io |
| jsonplaceholder | Public REST sandbox | https://jsonplaceholder.typicode.com |

### B11. Diagram tools
| Tool | Type | Link |
|------|------|------|
| draw.io / diagrams.net | Web/Desktop | https://app.diagrams.net |
| Excalidraw | Web | https://excalidraw.com |
| Cloudcraft (free tier) | AWS diagrams | https://www.cloudcraft.co |
| Lucidchart Free | Web | https://www.lucidchart.com |

---

## Lab → Primary Tool Quick Map

| Lab | Headline tool(s) |
|-----|------------------|
| 1 | Docker (multiple containers as IaaS/PaaS/SaaS/FaaS) |
| 2 | HAProxy + Keepalived |
| 3 | ip netns, iptables |
| 4 | MinIO, NFS, fio |
| 5 | Consul + Docker |
| 6 | Docker, Docker Compose |
| 7 | QEMU, libvirt |
| 8 | Postgres, MongoDB |
| 9 | LocalStack, MinIO, AWS CLI |
| 10 | Nginx blue-green |
| 11 | HAProxy weighted canary |
| 12 | Docker Compose rolling |
| 13 | Terraform + LocalStack |
| 14 | Ansible |
| 15 | jq, yq |
| 16 | Prometheus + Grafana + node-exporter |
| 17 | ELK / OpenSearch |
| 18 | Jaeger + OpenTelemetry |
| 19 | Docker Compose + stress-ng |
| 20 | restic + MinIO |
| 21 | apt, unattended-upgrades, Docker tags |
| 22 | Trivy |
| 23 | Lynis, kube-bench, Docker Bench |
| 24 | Keycloak |
| 25 | OpenSSH + Google Authenticator PAM |
| 26 | HashiCorp Vault |
| 27 | ModSecurity + OWASP CRS |
| 28 | Falco |
| 29 | git + Gitea |
| 30 | act + GitHub Actions |
| 31 | curl, GraphQL Yoga, websocat |
| 32 | k3s + kubectl |
| 33 | Docker (resource & permission troubleshooting) |
| 34 | dig, mtr, ip, iptables |
| 35 | OpenSSL, nmap, gitleaks, auditd |
| 36 | Docker (CrashLoop / OOM / pull / DNS) |

---

All tools above are free of charge. The Killercoda VM is also free and disposable, so you can run every lab without spending or installing anything on your own machine — except the optional GUI tools in Section B.
