# Rajiv Wallace Home Lab - Infrastructure as Code

> **Portable, Containerized, Jenkins-orchestrated Infrastructure for Raspberry Pi 4B Home Lab**

A complete Infrastructure as Code (IaC) solution for deploying and managing a production-ready homelab environment. This project demonstrates DevOps best practices including containerization, secrets management, automated backups, monitoring, and disaster recovery.

## 🏗️ Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│                    Raspberry Pi 4B (DietPi)                  │
│                                                              │
│  ┌──────────────┐   ┌──────────────────────────────────────┐ │
│  │              │   │                                      │ │
│  │  Bootstrap   │   │    Jenkins-Orchestrated Services     │ │
│  │              │   │                                      │ │
│  │  • NPM       │──▶│  1. Vault (secrets)                  │ │
│  │  • Jenkins   │   │  2. Core (Pihole, Portainer)         │ │
│  │              │   │  3. Database (PostgreSQL, pgAdmin)   │ │
│  └──────────────┘   │  4. Monitoring (Prometheus, Grafana) │ │
│                     │  5. Media (Jellyfin)                 │ │
│                     │  6. Apps (Portfolio, Country Trivia) │ │
│                     └──────────────────────────────────────┘ │
│                                                              │
│  Backups: Google Cloud Storage (Encrypted) + Local USB       │
└──────────────────────────────────────────────────────────────┘
```

## 🚀 Features

- **Jenkins-Orchestrated Deployment**: Automated service deployment with pipeline jobs
- **HashiCorp Vault**: Centralized secrets management
- **Encrypted Backups**: Automated backups to Google Cloud Storage with GPG encryption
- **Network Segmentation**: Isolated Docker networks for security
- **Health Monitoring**: Prometheus + Grafana + Alertmanager with Discord notifications
- **Configuration as Code**: Jenkins CasC for reproducible CI/CD setup
- **Disaster Recovery**: Complete restore from backup in < 30 minutes

## 📁 Project Structure

```
home-lab-infrastucture/
├── foundation/                           # Initial setup
│   ├── docker-compose.foundation.yml
│   └── Makefile
├── networks/                             # Docker network definitions
│   └── create-networks.sh
├── services/                             # Service configurations
│   ├── core/
│   │    ├── nginx-proxy-manager/          # Pihole, Portainer, Watchtower
│   │    ├── jenkins/
│   │    │   ├── jobs/
│   │    │   ├── scripts/
│   │    │   └── config/
│   │    └── vault/
│   │        └── config/
│   ├── database/                         # PostgreSQL, pgAdmin
│   ├── monitoring/                       # Prometheus, Grafana, exporters
│   ├── media/                            # Jellyfin
│   └── applications/                     # Portfolio Website, Country Trivia
├── jenkins/                              # Jenkins job definitions
└── secrets/                              # Local secrets (not committed)
    └── .env.example
```

## 🎯 Quick Start

### Prerequisites

- Raspberry Pi 4B with DietPi (or similar Debian-based OS)
- Docker & Docker Compose installed
- Git installed
- Domain configured with Cloudflare (for \*.rajivwallace.com)

### Initial Setup (Fresh Install)

```bash
# 1. Clone the repository
git clone https://github.com/rajivghandi767/home-lab-infrastructure.git
cd home-lab-infrastructure

# 2. Create Docker networks
cd networks
chmod +x create-networks.sh
./create-networks.sh

# 3. Setup secrets
cd ../secrets
cp .env.example .env
# Edit .env with your actual secrets

# 4. Bootstrap NPM + Jenkins
cd ../bootstrap
make bootstrap

# Wait for services to start (check with: docker ps)
```

### Deployment via Jenkins

1. **Access Jenkins**: Navigate to `http://jenkins.rajivwallace.com`

2. **Configure NPM**: Access NPM at `http://npm.rajivwallace.com` and create proxy hosts for:

   - jenkins.rajivwallace.com → jenkins:8080
   - vault.rajivwallace.com → vault:8200
   - grafana.rajivwallace.com → grafana:3000
   - portainer.rajivwallace.com → portainer:3000

3. **Run Deployment Pipeline**:

   - Go to Jenkins → `Infrastructure/00-Deploy-All-Services`
   - Click "Build with Parameters"
   - Select restore options
   - Click "Build"

4. **Monitor Progress**: Watch the pipeline execute through all stages

## 🔐 Secrets Management

### Environment Variables

All secrets are stored in `secrets/.env` (not committed to Git):

```bash
# Jenkins
JENKINS_ADMIN_PASSWORD=your_password

# Backup encryption
BACKUP_ENCRYPTION_KEY=your_gpg_passphrase

# GCS
GCS_SERVICE_ACCOUNT_KEY=base64_encoded_key
```

## 💾 Backup & Restore

### Automated Backups

Backups run daily at 2 AM via Jenkins cron job:

```bash
# Manual backup trigger
Jenkins → Backups/Backup-All-Services → Build Now
```

### Restore from Backup

```bash
# Full system restore
Jenkins → Infrastructure/00-Deploy-All-Services
- Set RESTORE_FROM_BACKUP: true
- Set BACKUP_DATE: latest (or YYYY-MM-DD)
- Build
```

### Google Cloud Storage Setup

1. Create GCS bucket:

```bash
gsutil mb -l us-east1 gs://homelab-backups-rajiv
```

2. Create service account and download JSON key

3. Base64 encode the key:

```bash
base64 -i gcs-key.json | tr -d '\n'
# Add output to secrets/.env as GCS_SERVICE_ACCOUNT_KEY
```

## 🌐 Network Architecture

| Network      | Purpose               | Services                               |
| ------------ | --------------------- | -------------------------------------- |
| `core`       | Core infrastructure   | NPM, Pihole, Vault                     |
| `management` | Container management  | Jenkins, Portainer, Watchtower         |
| `database`   | Database services     | PostgreSQL, pgAdmin, postgres-exporter |
| `monitoring` | Monitoring & alerting | Prometheus, Grafana, Alertmanager      |
| `media`      | Media                 | Jellyfin                               |
| `portfolio`  | Portfolio Website     | Frontend, Backend, nginx, Postgres     |
| `trivia`     | Country Trivia        | Frontend, Backend, nginx, Postgres     |

## 📊 Monitoring

### Access Dashboards

- **Grafana**: https://grafana.rajivwallace.com
- **Prometheus**: https://prometheus.rajivwallace.com
- **Alertmanager**: https://alertmanager.rajivwallace.com

### Alert Configuration

Alerts are sent to Discord via webhook. Configure in `services/monitoring/alertmanager.yml`.

Critical alerts:

- Service down > 1 minute
- High CPU > 80% for 5 minutes
- Low disk space < 15%
- High error rate > 5%

## 🛠️ Common Operations

### View All Containers

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Check Service Logs

```bash
docker logs -f <container_name>
```

### Restart a Service

```bash
cd services/<service_directory>
docker-compose restart
```

### Update Services

Watchtower automatically updates containers daily. To manually trigger:

```bash
docker exec watchtower /watchtower --run-once
```

## 🚨 Disaster Recovery

### Complete System Recovery

1. **New Raspberry Pi Setup**:

```bash
# Install Git, Docker & Docker Compose
git clone https://github.com/rajivghandi767/home-lab-infrastructure
cd home-lab-infrastructure
```

2. **Restore Secrets** from USB backup:

```bash
cp /media/usb/secrets/.env secrets/.env
```

3. **Foundation**:

```bash
cd foundation
make networks
make foundation
```

4. **Restore Everything** via Jenkins:
   - Access Jenkins
   - Run `Infrastructure/00-Deploy-All-Services`
   - Wait ~20 minutes

**Recovery Time Objective (RTO)**: < 30 minutes  
**Recovery Point Objective (RPO)**: < 24 hours

## 📚 Documentation

- [Architecture Details](docs/ARCHITECTURE.md)
- [Backup & Restore Procedures](docs/BACKUP_RESTORE.md)
- [Network Topology](docs/NETWORK_TOPOLOGY.md)
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md)

## 🔧 Technology Stack

| Category         | Technology                           |
| ---------------- | ------------------------------------ |
| OS               | DietPi (Debian)                      |
| Containerization | Docker, Docker Compose               |
| Orchestration    | Jenkins (with JobDSL, CasC)          |
| Secrets          | HashiCorp Vault                      |
| Networking       | Nginx Proxy Manager, Cloudflare      |
| Monitoring       | Prometheus, Grafana, Alertmanager    |
| Backup           | Google Cloud Storage, GPG encryption |
| DNS/Ad-blocking  | Pihole                               |
| Media            | Jellyfin                             |

## Adapting for Your Own Homelab?

To use this for your own infrastructure:

1. Fork this repository
2. Find and replace `rajivwallace.com` with your domain
3. Update `secrets/.env.example` with your own placeholders
4. Modify service configurations as needed
5. Review network topology for your requirements

## 📝 License

MIT License - See [LICENSE](LICENSE) for details

## 👤 Author

**Rajiv Wallace**

- Portfolio: https://rajivwallace.com
- GitHub: [@rajivghandi767](https://github.com/rajivghandi767)
- LinkedIn: [Rajiv Wallace](https://linkedin.com/in/rajiv-wallace)

---

**Note**: This is a production infrastructure project showcasing real-world DevOps practices. All services run on a single Raspberry Pi 4B (Quad-Core + 8GB RAM) demonstrating efficient resource utilization and proper architectural patterns.
