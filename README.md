# Production Infrastructure Platform for Home Lab

Professional-grade infrastructure demonstrating enterprise DevOps practices with automated CI/CD, centralized secret management, monitoring, and disaster recovery.

## Architecture

**Core Services:**

- **Nginx Proxy Manager**: SSL-terminated reverse proxy with automated certificates
- **Jenkins**: CI/CD orchestration with Infrastructure as Code pipelines
- **HashiCorp Vault**: Centralized secret management with automated credential lifecycle
- **PostgreSQL + pgAdmin**: Production database with web administration
- **Prometheus + Grafana**: Complete observability stack with Discord alerting
- **Automated Backups**: GPG-encrypted backups with three-phase disaster recovery

**Key Features:**

- Jenkins-orchestrated infrastructure deployment
- Zero secrets in Git repository
- Complete infrastructure reproducible from code
- Optimized for Raspberry Pi 4B (8GB RAM)

## Quick Start

### Prerequisites

- Raspberry Pi 4B (8GB RAM) or compatible Linux host
- Docker 20.10+ and Docker Compose 2.0+
- Domain name with DNS configuration (Cloudflare is my preference!)

### Setup

```bash
git clone https://github.com/rajiv-wallace/home-lab-infrastructure.git
cd home-lab-infrastructure
make setup

# Edit environment variables
cp .env.template .env
nano .env

# Initialize and deploy
make init-vault
make deploy
```

### Deployment Options

```bash
make deploy      # Professional infrastructure only
make deploy-full # Add personal services (Pi-hole, Jellyfin, Portainer)
make status      # Check service health
make logs        # Monitor logs
```

## Operations

### Daily Operations

```bash
make status       # Service health and resource usage
make backup       # Create encrypted backup
make logs         # Follow service logs
```

### Disaster Recovery

```bash
make recovery-phase1    # Restore core infrastructure
make recovery-phase2    # Restore Jenkins and Vault keys
make recovery-phase3    # Jenkins orchestrates full recovery
```

### Maintenance

```bash
make update       # Update container images
make clean        # Clean Docker resources
make vault-status # Check Vault health
```

## Technical Details

### Service Dependencies

1. **Nginx Proxy Manager**: Core routing and SSL
2. **Jenkins + Vault**: Parallel orchestration and secret management
3. **Database**: PostgreSQL with monitoring integration
4. **Observability**: Prometheus metrics with Grafana dashboards

### Resource Allocation (Pi 4B)

| Service        | Memory     | CPU      | Purpose                          |
| -------------- | ---------- | -------- | -------------------------------- |
| Jenkins        | 1500MB     | 2.0      | CI/CD orchestration              |
| PostgreSQL     | 1200MB     | 1.0      | Database                         |
| Prometheus     | 800MB      | 1.0      | Metrics                          |
| Other services | ~1400MB    | ~2.0     | Proxy, Vault, Grafana, exporters |
| **Total**      | **~4.9GB** | **~6.0** | **Leaves 3GB free**              |

### Security Model

- All secrets managed through Vault with Jenkins orchestration
- GPG-encrypted backups with strong passphrases
- Network segmentation by service function
- Automatic SSL certificates with HTTPS enforcement

### Monitoring

- System metrics via node-exporter
- Container metrics via cAdvisor
- Database metrics via postgres-exporter
- Custom dashboards with proactive alerting

## Project Structure

```
docker-infrastructure/
├── docker-compose.yml              # Professional Services
├── docker-compose.personal.yml     # Personal Services
├── config/                         # Service Configurations
├── scripts/                        # Automation Scripts
├── jenkinsfiles/                   # CI/CD Pipeline Definitions
└── docs/                           # Detailed Documentation
```

## Documentation

- [Deployment Guide](docs/DEPLOYMENT.md) - Step-by-step setup
- [Architecture Guide](docs/ARCHITECTURE.md) - Design decisions
- [Disaster Recovery](docs/RECOVERY.md) - Recovery procedures
- [Monitoring Setup](docs/MONITORING.md) - Observability configuration

## Professional Use Cases

**Portfolio Demonstration:** Complete DevOps platform showcasing Infrastructure as Code, CI/CD automation, secret management, and operational excellence.

**Development Environment:** Production-like infrastructure for testing applications with proper monitoring and database management.

**Learning Platform:** Hands-on experience with enterprise tools and patterns including Vault, Jenkins, Prometheus, and disaster recovery procedures.

**Migration Tool:** Comprehensive tool for restoring services when doing clean OS installs or upgrading server hardware.
