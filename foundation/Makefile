.PHONY: help init networks restore-foundation foundation up down restart logs status clean backup-usb restore-usb health

help:
	@echo "════════════════════════════════════════════════════════"
	@echo "  rwDietPi Home Lab IaC - Infrastructure Management"
	@echo "════════════════════════════════════════════════════════"
	@echo ""
	@echo "🚀 Initial Setup:"
	@echo "  make init                     - Complete first-time setup (networks + restore + start)"
	@echo "  make networks                 - Create all Docker networks"
	@echo "  make restore-foundation       - Restore NPM + Jenkins from GCS backups"
	@echo "  make foundation               - Start NPM + Jenkins (without restore)"
	@echo ""
	@echo "🔧 Daily Operations:"
	@echo "  make up                       - Start foundation services"
	@echo "  make down                     - Stop foundation services"
	@echo "  make restart                  - Restart foundation services"
	@echo "  make logs                     - View logs (Ctrl+C to exit)"
	@echo "  make status                   - Show service status"
	@echo "  make health                   - Check health of all services"
	@echo ""
	@echo "💾 Backup Operations:"
	@echo "  make backup-usb               - Backup secrets to USB"
	@echo "  make restore-usb              - Restore secrets from USB"
	@echo ""
	@echo "🧹 Maintenance:"
	@echo "  make clean                    - Stop and remove containers/volumes (DANGEROUS)"
	@echo ""
	@echo "═══════════════════════════════════════════════════════════"
	@echo "📖 Disaster Recovery? Run: make init"
	@echo "📖 Fresh Install?     Run: make networks && make foundation"
	@echo "═══════════════════════════════════════════════════════════"

init: networks restore-foundation foundation
	@echo ""
	@echo "════════════════════════════════════════════════════════"
	@echo "✅ Initialization Complete!"
	@echo "════════════════════════════════════════════════════════"
	@echo ""
	@echo "📍 Access Points:"
	@echo "   NPM UI:  https://nginx.rajivwallace.com"
	@echo "   Jenkins: https://jenkins.rajivwallace.com"
	@echo ""
	@echo "✓ NPM and Jenkins restored from backups"
	@echo "✓ All proxy hosts should be configured"
	@echo ""
	@echo "⏭️  Next Steps:"
	@echo "   1. Verify NPM proxy hosts at https://nginx.rajivwallace.com"
	@echo "   2. Wait for Jenkins to fully start (~2 minutes)"
	@echo "   3. Access Jenkins and run deployment pipeline:"
	@echo "      Infrastructure/00-Deploy-All-Services"
	@echo ""
	@echo "💡 Tip: Run 'make logs' to watch startup progress"
	@echo "════════════════════════════════════════════════════════"

networks:
	@echo "🌐 Creating Docker Networks..."
	@cd ../networks && chmod +x create-networks.sh && ./create-networks.sh
	@echo ""

restore-foundation:
	@echo "📥 Restoring foundation services from GCS backups..."
	@echo ""
	@if [ ! -f "../secrets/.env" ]; then \
		echo "❌ secrets/.env not found"; \
		echo "   Cannot proceed without GCS credentials"; \
		exit 1; \
	fi
	@. ../secrets/.env && \
	if [ -z "$BACKUP_ENCRYPTION_KEY" ] || [ -z "$GCS_SERVICE_ACCOUNT_KEY" ]; then \
		echo "❌ Missing GCS credentials in secrets/.env"; \
		echo "   Required: BACKUP_ENCRYPTION_KEY, GCS_SERVICE_ACCOUNT_KEY"; \
		exit 1; \
	fi
	@echo "Authenticating with GCS..."
	@. ../secrets/.env && \
	echo "$GCS_SERVICE_ACCOUNT_KEY" | foundation64 -d > /tmp/gcs-key.json && \
	gcloud auth activate-service-account --key-file=/tmp/gcs-key.json && \
	rm /tmp/gcs-key.json
	@echo ""
	@echo "Downloading NPM backup..."
	@. ../secrets/.env && \
	mkdir -p /tmp/npm-restore && \
	gsutil cp gs://home-lab-infrastructure-backups-rajiv/nginx-proxy-manager/nginx-proxy-manager-data-latest.tar.gz.enc /tmp/npm-restore/ 2>/dev/null || \
	gsutil cp gs://home-lab-infrastructure-backups-rajiv/npm/npm-data-latest.tar.gz.enc /tmp/npm-restore/backup.tar.gz.enc 2>/dev/null || \
	(echo "⚠️  No NPM backup found in GCS, skipping NPM restore" && rm -rf /tmp/npm-restore)
	@if [ -d "/tmp/npm-restore" ] && [ -f "/tmp/npm-restore/"*.enc ]; then \
		echo "Decrypting and extracting NPM data..."; \
		. ../secrets/.env && \
		mkdir -p ../services/nginx-proxy-manager/data && \
		echo "$BACKUP_ENCRYPTION_KEY" | gpg --batch --yes --passphrase-fd 0 --decrypt /tmp/npm-restore/*.enc | tar -xzf - -C ../services/nginx-proxy-manager/ && \
		echo "✓ NPM restored from backup" && \
		rm -rf /tmp/npm-restore; \
	fi
	@echo ""
	@echo "Downloading Jenkins backup..."
	@. ../secrets/.env && \
	mkdir -p /tmp/jenkins-restore && \
	gsutil cp gs://home-lab-infrastructure-backups-rajiv/jenkins/jenkins-data-latest.tar.gz.enc /tmp/jenkins-restore/ 2>/dev/null || \
	(echo "⚠️  No Jenkins backup found in GCS, skipping Jenkins restore" && rm -rf /tmp/jenkins-restore)
	@if [ -d "/tmp/jenkins-restore" ] && [ -f "/tmp/jenkins-restore/jenkins-data-latest.tar.gz.enc" ]; then \
		echo "Decrypting and extracting Jenkins data..."; \
		. ../secrets/.env && \
		mkdir -p ../services/jenkins/jenkins_home && \
		echo "$BACKUP_ENCRYPTION_KEY" | gpg --batch --yes --passphrase-fd 0 --decrypt /tmp/jenkins-restore/jenkins-data-latest.tar.gz.enc | tar -xzf - -C ../services/jenkins/ && \
		echo "✓ Jenkins restored from backup" && \
		rm -rf /tmp/jenkins-restore; \
	fi
	@echo ""
	@echo "✅ foundation services restoration complete"
	@echo ""

foundation: networks
	@echo "🚀 Starting foundation services (NPM + Jenkins)..."
	@echo ""
	@if [ ! -f "../secrets/.env" ]; then \
		echo "⚠️  Warning: secrets/.env not found"; \
		echo "   Copy secrets/.env.example to secrets/.env and configure it"; \
		read -p "   Continue anyway? (y/n): " confirm; \
		if [ "$confirm" != "y" ]; then exit 1; fi; \
	fi
	@docker compose -f docker-compose.foundation.yml up -d
	@echo ""
	@echo "⏳ Waiting for services to start..."
	@sleep 5
	@echo ""
	@docker compose -f docker-compose.foundation.yml ps

up:
	@echo "▶️  Starting foundation services..."
	@docker compose -f docker-compose.foundation.yml up -d
	@sleep 3
	@docker compose -f docker-compose.foundation.yml ps

down:
	@echo "⏹️  Stopping foundation services..."
	@docker compose -f docker-compose.foundation.yml down
	@echo "✅ Services stopped"

restart:
	@echo "🔄 Restarting foundation services..."
	@docker compose -f docker-compose.foundation.yml restart
	@sleep 3
	@docker compose -f docker-compose.foundation.yml ps

logs:
	@echo "📋 Showing logs (Ctrl+C to exit)..."
	@echo ""
	@docker compose -f docker-compose.foundation.yml logs -f

status:
	@echo "📊 foundation services status:"
	@echo ""
	@docker compose -f docker-compose.foundation.yml ps
	@echo ""
	@echo "📊 All Infrastructure Containers:"
	@echo ""
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No containers running"

health:
	@echo "🏥 Health Check Report"
	@echo "════════════════════════════════════════════════════════"
	@echo ""
	@echo "Core Services:"
	@docker ps --filter "name=nginx" --filter "name=jenkins" --filter "name=vault" --filter "name=pihole" --filter "name=portainer" --filter "name=watchtower" --format "  ✓ {{.Names}}: {{.Status}}" 2>/dev/null || echo "  ✗ No core services running"
	@echo ""
	@echo "Database Services:"
	@docker ps --filter "name=postgres" --filter "name=pgadmin" --format "  {{.Names}}: {{.Status}}" 2>/dev/null || echo "  (No database services running)"
	@echo ""
	@echo "Monitoring Services:"
	@docker ps --filter "name=prometheus" --filter "name=grafana" --filter "name=alertmanager" --format "  {{.Names}}: {{.Status}}" 2>/dev/null || echo "  (No monitoring services running)"
	@echo ""
	@echo "Media:"
	@docker ps --filter "name=jellyfin" --format "  {{.Names}}: {{.Status}}" 2>/dev/null || echo "  (No media services running)"
	@echo ""
	@echo "Deployed Applications:"
	@docker ps --filter "name=portfolio-website" --filter "name=country-trivia" --format "  {{.Names}}: {{.Status}}" 2>/dev/null || echo "  (No apps deployed yet)"
	@echo ""
	@echo "════════════════════════════════════════════════════════"
	@echo ""
	@echo "🌐 Network Status:"
	@docker network ls | grep -E "core|management|database|monitoring|media|portfolio|trivia" 2>/dev/null || echo "  Networks not yet created"
	@echo ""

backup-usb:
	@echo "💾 Backing up secrets to USB..."
	@if [ ! -d "/media/usb" ]; then \
		echo "❌ USB not mounted at /media/usb"; \
		echo "   Mount your USB drive first:"; \
		echo "   sudo mount /dev/sda1 /media/usb"; \
		exit 1; \
	fi
	@mkdir -p /media/usb/home-lab-infrastructure-backup/secrets
	@if [ -f "../secrets/.env" ]; then \
		cp ../secrets/.env /media/usb/home-lab-infrastructure-backup/secrets/ && \
		echo "✅ Backed up .env"; \
	else \
		echo "⚠️  secrets/.env not found, skipping"; \
	fi
	@echo ""
	@echo "💡 To also backup GCS data, run:"
	@echo "   gsutil -m rsync -r gs://home-lab-infrastructure-backups-rajiv /media/usb/home-lab-infrastructure-backup/gcs/"

restore-usb:
	@echo "📥 Restoring secrets from USB..."
	@if [ ! -d "/media/usb/home-lab-infrastructure-backup/secrets" ]; then \
		echo "❌ Backup not found at /media/usb/home-lab-infrastructure-backup/secrets"; \
		echo "   Is your USB drive mounted?"; \
		exit 1; \
	fi
	@if [ -f "/media/usb/home-lab-infrastructure-backup/secrets/.env" ]; then \
		cp /media/usb/home-lab-infrastructure-backup/secrets/.env ../secrets/.env && \
		echo "✅ Restored .env"; \
	else \
		echo "❌ .env not found in backup"; \
		exit 1; \
	fi
	@echo "✅ Secrets restored successfully"

clean:
	@echo "⚠️  WARNING: This will stop and remove foundation containers and volumes!"
	@echo "   This action cannot be undone."
	@echo ""
	@read -p "   Are you absolutely sure? Type 'yes' to confirm: " confirm; \
	if [ "$confirm" = "yes" ]; then \
		echo ""; \
		echo "🧹 Cleaning up..."; \
		docker-compose -f docker-compose.foundation.yml down -v; \
		echo "✅ Cleanup complete"; \
	else \
		echo "❌ Cancelled"; \
	fi