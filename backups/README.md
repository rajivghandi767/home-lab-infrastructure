# Backups Directory

This directory is for **LOCAL backups only** and is **NOT committed to Git**.

## Structure

Cloud backups are stored in Google Cloud Storage at:

```
gs://homelab-backups-rajiv/
├── npm/
│   └── nginx-proxy-manager-data-YYYY-MM-DD.tar.gz.enc
├── jenkins/
│   └── jenkins-data-YYYY-MM-DD.tar.gz.enc
├── vault/
│   └── vault-data-YYYY-MM-DD.tar.gz.enc
├── pihole/
│   └── pihole-data-YYYY-MM-DD.tar.gz.enc
├── portainer/
│   └── portainer-data-YYYY-MM-DD.tar.gz.enc
├── postgres-dev/
│   └── postgres-dev-data-YYYY-MM-DD.tar.gz.enc
├── grafana/
│   └── grafana-data-YYYY-MM-DD.tar.gz.enc
├── prometheus/
│   └── prometheus-data-YYYY-MM-DD.tar.gz.enc
├── portfolio-website/
│   └── portfolio-data-YYYY-MM-DD.tar.gz.enc
├── trivia-app/
│   └── trivia-data-YYYY-MM-DD.tar.gz.enc
└── jellyfin/
    └── jellyfin-data-YYYY-MM-DD.tar.gz.enc
```

## Local USB Backup

For disaster recovery, keep a local copy on an external USB drive:

```bash
# Mount USB drive
sudo mount /dev/sda1 /media/usb #Edit your mount drive path to match

# Copy secrets
mkdir -p /media/usb/homelab-backup/secrets
cp secrets/.env /media/usb/homelab-backup/secrets/

# Download latest backups from GCS
gsutil -m rsync -r gs://homelab-backups-rajiv /media/usb/homelab-backup/gcs/

# Unmount
sudo umount /media/usb
```

## Restoring from Local Backup

If GCS is unavailable, you can restore from local USB:

```bash
# Copy secrets
cp /media/usb/homelab-backup/secrets/.env secrets/.env

# Copy backups to local directory
cp -r /media/usb/homelab-backup/gcs/* backups/

# Then use Jenkins restore jobs or manual restore
```
