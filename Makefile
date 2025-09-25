# =============================================================================
# Professional Home Lab Infrastructure Makefile
# Automation commands for enterprise-grade infrastructure management
# =============================================================================

.PHONY: help setup init-vault deploy deploy-full status logs health backup clean update

# Default target
help: ## Show available commands
	@echo ''
	@echo 'Infrastructure Management Commands:'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ''

# =============================================================================
# Setup and Initialization
# =============================================================================

setup: ## Initial Project Setup - Create directories and environment
	@echo "Setting up infrastructure project..."
	mkdir -p backups .secrets data logs tmp config
	cp .env.template .env
	chmod +x scripts/*.sh
	chmod 700 .secrets
	@echo "Setup complete!"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Edit .env with your Vault token and backup passphrase"
	@echo "  2. Run 'make init-vault' to initialize Vault"
	@echo "  3. Run 'make deploy' to start infrastructure"

init-vault: ## Initialize Vault for first time (creates unseal keys)
	@echo "Initializing Vault..."
	@./scripts/vault-init.sh

# =============================================================================
# Infrastructure Deployment
# =============================================================================

deploy: ## Deploy professional infrastructure only
	@echo "Deploying professional infrastructure..."
	docker-compose up -d
	@echo "Professional infrastructure deployed!"
	@echo ""
	@echo "Services Available:"
	@echo "  - Jenkins: https://jenkins.rajivwallace.com"
	@echo "  - Vault: https://vault.rajivwallace.com" 
	@echo "  - Grafana: https://grafana.rajivwallace.com"
	@echo "  - pgAdmin: https://pgadmin.rajivwallace.com"

deploy-full: ## Deploy complete homelab (professional + personal)
	@echo "Deploying full homelab infrastructure..."
	docker-compose -f docker-compose.yml -f docker-compose.personal.yml up -d
	@echo "Complete infrastructure deployed!"
	@echo ""
	@echo "Additional services:"
	@echo "  - Pi-hole: https://pihole.rajivwallace.com"
	@echo "  - Jellyfin: https://jellyfin.rajivwallace.com"
	@echo "  - Portainer: https://portainer.rajivwallace.com"

start: ## Start all currently configured services
	docker-compose up -d

start-full: ## Start all services (professional + personal)
	docker-compose -f docker-compose.yml -f docker-compose.personal.yml up -d

stop: ## Stop all services
	docker-compose -f docker-compose.yml -f docker-compose.personal.yml down

restart: ## Restart all services
	docker-compose -f docker-compose.yml -f docker-compose.personal.yml restart

# =============================================================================
# Monitoring and Status
# =============================================================================

status: ## Show service status and resource usage
	@echo "Infrastructure Status Report"
	@echo "============================"
	@echo ""
	@echo "Container Status:"
	@docker-compose -f docker-compose.yml -f docker-compose.personal.yml ps 2>/dev/null || docker-compose ps
	@echo ""
	@echo "Resource Usage:"
	@docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" 2>/dev/null | head -20

health: ## Run comprehensive health checks
	@echo "Health Check Report"
	@echo "==================="
	@docker-compose ps --filter "status=running" --format "table {{.Name}}\t{{.Status}}" 2>/dev/null || echo "No services running"
	@echo ""
	@echo "Vault Status:"
	@vault status 2>/dev/null || echo "Vault not accessible"

logs: ## Follow logs for all services
	docker-compose logs -f

logs-professional: ## Follow logs for professional services only
	docker-compose logs -f

logs-service: ## Follow logs for specific service (usage: make logs-service SERVICE=jenkins)
	@if [ -z "$(SERVICE)" ]; then echo "Usage: make logs-service SERVICE=jenkins"; exit 1; fi
	docker-compose logs -f $(SERVICE)

# =============================================================================
# Backup and Recovery
# =============================================================================

backup: ## Create encrypted backup
	@echo "Creating infrastructure backup..."
	@./scripts/backup.sh
	@echo "Backup completed"
	@ls -lah backups/ 2>/dev/null || echo "No backups directory found"

list-backups: ## List available backups
	@echo "Available Backups:"
	@ls -lah backups/ 2>/dev/null || echo "No backups found"

# Disaster Recovery - Three Phase Process
recovery-phase1: ## Phase 1: Decrypt backup and restore core routing
	@echo "RECOVERY - Phase 1"
	@echo "============================="
	@echo "This will decrypt backup and restore NPM routing"
	@./scripts/recovery-phase1.sh

recovery-phase2: ## Phase 2: Restore Jenkins with Vault keys
	@echo "RECOVERY - Phase 2"
	@echo "============================="
	@echo "This will restore Jenkins with unsealing capabilities"
	@./scripts/recovery-phase2.sh

recovery-phase3: ## Phase 3: Trigger Jenkins recovery pipeline
	@echo "RECOVERY - Phase 3"
	@echo "============================="
	@echo "Triggering Jenkins recovery pipeline via script..."
	@echo "The decrypted backups are available at /tmp/recovery/"
	@./scripts/recovery-phase3.sh

recovery-cleanup: ## Clean up decrypted backup files for security
	@echo "Cleaning up decrypted backup data..."
	sudo rm -rf /tmp/recovery
	@echo "Security cleanup completed"

# =============================================================================
# Vault Management
# =============================================================================

vault-status: ## Check Vault status
	@echo "Vault Status:"
	@vault status || echo "Vault sealed or unreachable"

vault-unseal: ## Manual Vault unseal (if needed)
	@echo "Manual Vault unseal - enter 3 unseal keys when prompted"
	@vault operator unseal

vault-seal: ## Seal Vault (emergency use)
	@echo "Sealing Vault..."
	@vault operator seal

# =============================================================================
# Maintenance and Updates
# =============================================================================

update: ## Update all container images
	@echo "Updating container images..."
	docker compose -f docker-compose.yml -f docker-compose.personal.yml pull
	docker compose -f docker-compose.yml -f docker-compose.personal.yml up -d
	@echo "Update completed"

clean: ## Clean up Docker resources
	@echo "Cleaning up Docker resources..."
	docker system prune -f
	@echo "Cleanup completed"

clean-volumes: ## DANGER: Clean up Docker volumes (removes data)
	@echo "WARNING: This will remove Docker volumes and ALL DATA"
	@echo "Type 'yes' to confirm:"
	@read -r REPLY && [ "$$REPLY" = "yes" ] || (echo "Cancelled" && exit 1)
	docker-compose -f docker-compose.yml -f docker-compose.personal.yml down -v
	docker volume prune -f
	@echo "Volume cleanup completed"

reset: ## DANGER: Complete infrastructure reset
	@echo "WARNING: This will DELETE ALL DATA including backups!"
	@echo "Type 'RESET' to confirm:"
	@read -r REPLY && [ "$$REPLY" = "RESET" ] || (echo "Reset cancelled" && exit 1)
	docker-compose -f docker-compose.yml -f docker-compose.personal.yml down -v
	docker system prune -af --volumes
	sudo rm -rf data logs .secrets backups tmp
	@echo "Infrastructure reset completed"

# =============================================================================
# Development and Testing
# =============================================================================

config: ## Validate Docker Compose configuration
	@echo "Validating professional stack:"
	@docker compose config >/dev/null && echo "✓ Professional stack valid"
	@echo "Validating full stack:"
	@docker compose -f docker-compose.yml -f docker-compose.personal.yml config >/dev/null && echo "✓ Full stack valid"

shell: ## Open shell in specific service (usage: make shell SERVICE=jenkins)
	@if [ -z "$(SERVICE)" ]; then echo "Usage: make shell SERVICE=jenkins"; exit 1; fi
	docker-compose exec $(SERVICE) /bin/bash

ps: ## Show running containers
	@docker-compose -f docker-compose.yml -f docker-compose.personal.yml ps 2>/dev/null || docker-compose ps

# =============================================================================
# Documentation
# =============================================================================

docs: ## Show documentation links
	@echo "Documentation:"
	@echo "  README.md - Project overview"
	@echo "  docs/DEPLOYMENT.md - Deployment guide"
	@echo "  docs/RECOVERY.md - Recovery procedures"
	@echo "  docs/ARCHITECTURE.md - Infrastructure design"
	@echo "  docs/MONITORING.md - Observability setup"