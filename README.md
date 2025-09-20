# N8N Docker Setup

A flexible Docker setup for [n8n](https://n8n.io) with optional PostgreSQL and Valkey (Redis alternative) services. This template gives you full control over which services to enable based on your needs.

## 🚀 Quick Start

1. **Clone or download this template**
2. **Copy environment file**:
   ```bash
   cp .env.example .env
   ```
3. **Edit the `.env` file** with your preferred configuration
4. **Start n8n** (choose one option):

### Option 1: Using the Control Script (Recommended)
```bash
# Start n8n only (with SQLite)
./n8n-ctl.sh start

# Start n8n with PostgreSQL
./n8n-ctl.sh start postgres

# Start all services
./n8n-ctl.sh start full
```

### Option 2: Using Docker Compose Directly
```bash
# n8n only (SQLite)
docker-compose up -d n8n

# n8n + PostgreSQL
docker-compose --profile postgres up -d

# All services
docker-compose --profile full up -d
```

## 📋 Available Services

| Service | Description | Default Port | Profile |
|---------|-------------|--------------|---------|
| **n8n** | Workflow automation platform | 5678 | Always included |
| **PostgreSQL** | Database (alternative to SQLite) | 5432 | `postgres` |
| **Valkey** | Redis-compatible cache/queue | 6379 | `valkey` |
| **pgAdmin** | PostgreSQL web interface | 8080 | `postgres-ui` |
| **Valkey Commander** | Valkey/Redis web interface | 8081 | `valkey-ui` |
| **Traefik** | Reverse proxy & SSL termination | 80, 443, 8090 | `traefik` |
| **Watchtower** | Automatic container updates | - | `watchtower` |
| **Portainer** | Docker management web interface | 9010 | `portainer` |
| **Dozzle** | Real-time Docker logs viewer | 9999 | `dozzle` |

## 🎯 Service Profiles

Control which services to run using profiles:

### Minimal Setup
- **`n8n-only`** (default): Just n8n with SQLite
  ```bash
  ./n8n-ctl.sh start
  ```

### Database Options
- **`postgres`**: n8n + PostgreSQL
  ```bash
  ./n8n-ctl.sh start postgres
  ```

### Caching & Queues
- **`valkey`**: n8n + Valkey (for scaling)
  ```bash
  ./n8n-ctl.sh start valkey
  ```

### With Management UIs
- **`postgres-ui`**: postgres + pgAdmin
  ```bash
  ./n8n-ctl.sh start postgres-ui
  ```
- **`valkey-ui`**: valkey + Valkey Commander
  ```bash
  ./n8n-ctl.sh start valkey-ui
  ```

### Reverse Proxy & SSL
- **`traefik`**: n8n + Traefik reverse proxy
  ```bash
  ./n8n-ctl.sh start traefik
  ```
- **`ssl`**: n8n + Traefik with SSL certificates
  ```bash
  ./n8n-ctl.sh start ssl
  ```

### Automatic Updates
- **`watchtower`**: n8n + automatic container updates
  ```bash
  ./n8n-ctl.sh start watchtower
  ```

### Container Management & Monitoring
- **`portainer`**: n8n + Docker management web UI
  ```bash
  ./n8n-ctl.sh start portainer
  ```
- **`dozzle`**: n8n + real-time Docker logs viewer
  ```bash
  ./n8n-ctl.sh start dozzle
  ```
- **`management-ui`**: All management UIs (Portainer + Dozzle)
  ```bash
  ./n8n-ctl.sh start management-ui
  ```

### Everything
- **`full`**: All services (without SSL)
  ```bash
  ./n8n-ctl.sh start full
  ```
- **`full-ssl`**: All services + Traefik with SSL
  ```bash
  ./n8n-ctl.sh start full-ssl
  ```
- **`full-ui`**: All services + management UIs
  ```bash
  ./n8n-ctl.sh start full-ui
  ```

## 🛠️ Control Script Usage

The `n8n-ctl.sh` script provides easy management:

```bash
# Service control
./n8n-ctl.sh start [profile]    # Start services
./n8n-ctl.sh stop               # Stop all services
./n8n-ctl.sh restart [profile]  # Restart services
./n8n-ctl.sh status             # Show service status

# Monitoring
./n8n-ctl.sh logs              # Show all logs
./n8n-ctl.sh logs n8n          # Show specific service logs

# Data management
./n8n-ctl.sh backup            # Backup n8n data
./n8n-ctl.sh restore backup.tar.gz  # Restore from backup
./n8n-ctl.sh clean             # Remove all data (destructive!)

# Help
./n8n-ctl.sh help              # Show usage information
```

## 🔧 Configuration

### Environment Variables

Key settings in `.env` file:

```bash
# N8N Configuration
N8N_PORT=5678                    # n8n web interface port
N8N_ENCRYPTION_KEY=              # Auto-generated if empty
N8N_JWT_SECRET=                  # Auto-generated if empty
WEBHOOK_URL=http://localhost:5678/

# Database (sqlite or postgresdb)
DB_TYPE=sqlite                   # Change to 'postgresdb' for PostgreSQL
POSTGRES_USER=n8n
POSTGRES_PASSWORD=n8n123
POSTGRES_DB=n8n

# Valkey/Redis
REDIS_PASSWORD=                  # Leave empty for no password
REDIS_MAX_MEMORY=256mb

# Traefik & SSL
TRAEFIK_ENABLE=false            # Set to true for SSL/reverse proxy
DOMAIN_NAME=yourdomain.com      # Your domain name
N8N_DOMAIN=n8n.yourdomain.com   # n8n subdomain
ACME_EMAIL=admin@yourdomain.com # Email for Let's Encrypt

# Watchtower (automatic updates)
WATCHTOWER_CLEANUP=true         # Remove old images after update
WATCHTOWER_POLL_INTERVAL=21600  # Check for updates every 6 hours
WATCHTOWER_SCHEDULE=            # Cron schedule (optional)

# Container Management UIs
PORTAINER_PORT=9010             # Docker management interface
DOZZLE_PORT=9999               # Docker logs viewer
DOZZLE_USERNAME=admin          # Dozzle login username
DOZZLE_PASSWORD=admin123       # Dozzle login password

# UI Tools
PGADMIN_PORT=8080
PGADMIN_EMAIL=admin@n8n.local
PGADMIN_PASSWORD=admin123
REDIS_COMMANDER_PORT=8081
```

### Database Setup

#### SQLite (Default)
- **Pros**: Simple, no extra services needed
- **Cons**: Single file, not suitable for high-load or multi-instance setups
- **Config**: `DB_TYPE=sqlite` in `.env`

#### PostgreSQL
- **Pros**: Robust, scalable, supports concurrent access
- **Cons**: Requires additional container
- **Config**: `DB_TYPE=postgresdb` in `.env`
- **Start**: `./n8n-ctl.sh start postgres`

### Scaling with Valkey

For production or high-load scenarios:
1. Enable Valkey: `./n8n-ctl.sh start valkey`
2. Configure n8n to use Valkey for queues and caching
3. Consider running multiple n8n instances behind a load balancer

### SSL & Reverse Proxy with Traefik

For production deployments with SSL certificates:

1. **Configure your domain** in `.env`:
   ```bash
   DOMAIN_NAME=yourdomain.com
   N8N_DOMAIN=n8n.yourdomain.com
   ACME_EMAIL=admin@yourdomain.com
   ```

2. **Start with SSL**:
   ```bash
   ./n8n-ctl.sh start ssl
   ```

3. **Access services securely**:
   - n8n: `https://n8n.yourdomain.com`
   - Traefik Dashboard: `https://traefik.yourdomain.com`

#### Features:
- **Automatic SSL certificates** via Let's Encrypt
- **HTTP to HTTPS redirect**
- **Security headers** and rate limiting
- **Dashboard protection** with basic auth
- **Wildcard certificate support** (with Cloudflare DNS)

### Automatic Updates with Watchtower

Watchtower automatically updates your containers:

```bash
# Enable automatic updates
./n8n-ctl.sh start watchtower

# Monitor only (no updates)
WATCHTOWER_MONITOR_ONLY=true ./n8n-ctl.sh start watchtower

# Schedule updates (daily at 4 AM)
WATCHTOWER_SCHEDULE="0 0 4 * * *" ./n8n-ctl.sh start watchtower
```

**Features**:
- **Automatic image updates** for specified containers
- **Cleanup old images** after updates
- **Flexible scheduling** with cron expressions
- **Notification support** (Slack, email, webhooks)
- **Rollback protection** with health checks

### Container Management & Monitoring

Since Watchtower doesn't have a built-in web interface, the template includes dedicated management tools:

#### **Portainer - Complete Docker Management**
```bash
# Enable Docker management UI
./n8n-ctl.sh start portainer
```

**Features**:
- **Visual container management** - start, stop, restart containers
- **Resource monitoring** - CPU, memory, network usage
- **Log viewing** - real-time and historical container logs
- **Image management** - pull, build, deploy images
- **Network & volume management** - create and manage Docker resources
- **User access control** - role-based permissions

#### **Dozzle - Real-time Log Viewer**
```bash
# Enable log viewer UI
./n8n-ctl.sh start dozzle
```

**Features**:
- **Live log streaming** - watch container logs in real-time
- **Search and filtering** - find specific log entries
- **Multi-container view** - monitor multiple services
- **Clean interface** - focused on log analysis
- **Authentication** - secured with username/password

#### **Combined Management Setup**
```bash
# Start everything with management UIs
./n8n-ctl.sh start management-ui

# Or include in full setup
./n8n-ctl.sh start full-ui
```

**Access URLs**:
- **Portainer**: http://localhost:9010 (admin/admin123)
- **Dozzle**: http://localhost:9999 (admin/admin123)
- **Watchtower logs**: `./n8n-ctl.sh logs watchtower`

## 📁 Directory Structure

```
n8n-docker-setup/
├── docker-compose.yml          # Main compose file
├── .env.example               # Environment template
├── .env                       # Your configuration (created from .env.example)
├── n8n-ctl.sh                 # Control script
├── README.md                  # This file
├── backups/                   # Backup storage (auto-created)
├── n8n/
│   ├── backup/               # n8n backup mount point
│   └── custom-nodes/         # Custom n8n nodes
├── postgres/
│   └── init/                 # PostgreSQL initialization scripts
├── valkey/
│   └── valkey.conf          # Valkey configuration (optional)
├── pgadmin/
│   └── servers.json         # pgAdmin server definitions (optional)
└── traefik/
    ├── dynamic/             # Traefik dynamic configuration
    │   └── config.yml
    └── logs/               # Traefik access logs
```

## 🔐 Security Considerations

### Production Deployment

1. **Change default passwords** in `.env` file
2. **Configure domain and SSL**:
   ```bash
   DOMAIN_NAME=yourdomain.com
   N8N_DOMAIN=n8n.yourdomain.com
   ACME_EMAIL=admin@yourdomain.com
   TRAEFIK_ENABLE=true
   ```
3. **Generate strong secrets**:
   ```bash
   # The script auto-generates these, but you can create your own:
   openssl rand -base64 32  # For N8N_ENCRYPTION_KEY
   openssl rand -base64 32  # For N8N_JWT_SECRET
   ```
4. **Deploy with SSL**: `./n8n-ctl.sh start full-ssl`
5. **Configure firewall** to allow only ports 80, 443, and SSH
6. **Regular backups**: `./n8n-ctl.sh backup`
7. **Set up monitoring** and log aggregation

### SSL Certificate Management
- **Automatic renewals** via Let's Encrypt ACME
- **Wildcard certificates** supported with Cloudflare DNS
- **Certificate storage** in Docker volume `traefik_letsencrypt`
- **Custom certificates** can be added to `traefik/dynamic/`

### Domain Configuration Examples

**Single Domain**:
```bash
DOMAIN_NAME=example.com
N8N_DOMAIN=n8n.example.com
PGADMIN_DOMAIN=pgadmin.example.com
```

**Subdomains on same domain**:
```bash
DOMAIN_NAME=yourdomain.com
N8N_DOMAIN=workflows.yourdomain.com
PGADMIN_DOMAIN=db.yourdomain.com
VALKEY_COMMANDER_DOMAIN=cache.yourdomain.com
```

### Network Security
- All services communicate through an internal Docker network
- Only n8n and UI tools expose ports to the host
- Database and cache services are not directly accessible from outside

## 🚀 Advanced Usage

### Custom n8n Nodes
Place custom nodes in `./n8n/custom-nodes/` directory. They will be automatically loaded.

### Database Initialization
Place SQL scripts in `./postgres/init/` to run during PostgreSQL first startup.

### Valkey Configuration
Create `./valkey/valkey.conf` for custom Valkey settings.

### Multiple Environments
Create different `.env` files for different environments:
```bash
# Development
cp .env.example .env.dev

# Production
cp .env.example .env.prod

# Use specific env file
docker-compose --env-file .env.prod up -d
```

## 🔍 Monitoring & Logs

### View Logs
```bash
# All services
./n8n-ctl.sh logs

# Specific service
./n8n-ctl.sh logs n8n
./n8n-ctl.sh logs postgres
./n8n-ctl.sh logs valkey

# Follow logs in real-time
docker-compose logs -f n8n
```

### Health Checks
All services include health checks. View status:
```bash
./n8n-ctl.sh status
```

### Metrics (Optional)
Enable n8n metrics by setting `N8N_METRICS=true` in `.env`. Metrics will be available at `http://localhost:5678/metrics`.

## 🐛 Troubleshooting

### Common Issues

1. **Port already in use**
   - Change ports in `.env` file
   - Check with: `lsof -i :5678`

2. **Permission errors**
   - Ensure n8n-ctl.sh is executable: `chmod +x n8n-ctl.sh`
   - Check Docker permissions

3. **Database connection errors**
   - Ensure PostgreSQL is healthy: `docker-compose ps`
   - Check database credentials in `.env`

4. **n8n not accessible**
   - Verify container is running: `docker-compose ps`
   - Check logs: `./n8n-ctl.sh logs n8n`
   - Ensure correct port in browser

### Reset Everything
```bash
# Stop services and remove all data
./n8n-ctl.sh clean

# Start fresh
./n8n-ctl.sh start [profile]
```

## 📚 Useful Commands

```bash
# Check running containers
docker ps

# Access n8n container shell
docker exec -it n8n /bin/sh

# Access PostgreSQL
docker exec -it n8n-postgres psql -U n8n -d n8n

# Access Valkey CLI
docker exec -it n8n-valkey valkey-cli

# View resource usage
docker stats

# Clean up unused Docker resources
docker system prune -a
```

## 🔗 Access URLs

### Local Access (default)
- **n8n**: http://localhost:5678
- **pgAdmin**: http://localhost:8080 (if postgres-ui profile enabled)
- **Valkey Commander**: http://localhost:8081 (if valkey-ui profile enabled)
- **Traefik Dashboard**: http://localhost:8090 (if traefik profile enabled)
- **Portainer**: http://localhost:9010 (admin/admin123, if portainer profile enabled)
- **Dozzle**: http://localhost:9999 (admin/admin123, if dozzle profile enabled)

### SSL/Domain Access (with Traefik)
When using SSL profiles with proper domain configuration:
- **n8n**: https://n8n.yourdomain.com
- **pgAdmin**: https://pgadmin.yourdomain.com
- **Valkey Commander**: https://valkey.yourdomain.com
- **Traefik Dashboard**: https://traefik.yourdomain.com
- **Portainer**: https://portainer.yourdomain.com
- **Dozzle**: https://logs.yourdomain.com

> **Note**: Replace `yourdomain.com` with your actual domain configured in `.env`

## 📖 Additional Resources

- [n8n Documentation](https://docs.n8n.io/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Valkey Documentation](https://valkey.io/docs/)

## 📄 License

This template is provided as-is for educational and development purposes. Please check individual service licenses for production use.

---

**Happy Automating! 🚀**