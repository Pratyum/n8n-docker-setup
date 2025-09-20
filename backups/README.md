# Backups Directory

This directory stores n8n data backups created by the control script.

## Creating Backups

```bash
./n8n-ctl.sh backup
```

Backups are stored as compressed tar files with timestamps:
- `n8n_backup_20240101_120000.tar.gz`

## Restoring Backups

```bash
./n8n-ctl.sh restore backups/n8n_backup_20240101_120000.tar.gz
```

## What's Included

Backups contain:
- All n8n workflows
- Credentials (encrypted)
- Execution history
- Settings and configurations
- Custom nodes (if installed)

## Automatic Backups

For production setups, consider setting up automatic backups with cron:

```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * cd /path/to/n8n-docker-setup && ./n8n-ctl.sh backup

# Add weekly cleanup (keep last 4 weeks)
0 3 * * 0 find /path/to/n8n-docker-setup/backups -name "*.tar.gz" -mtime +28 -delete
```

## Backup Retention

Consider implementing a retention policy:
- Keep daily backups for 1 week
- Keep weekly backups for 1 month  
- Keep monthly backups for 1 year