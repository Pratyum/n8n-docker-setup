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

### Everything
- **`full`**: All services
  ```bash
  ./n8n-ctl.sh start full
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
└── pgadmin/
    └── servers.json         # pgAdmin server definitions (optional)
```

## 🔐 Security Considerations

### Production Deployment

1. **Change default passwords** in `.env` file
2. **Generate strong secrets**:
   ```bash
   # The script auto-generates these, but you can create your own:
   openssl rand -base64 32  # For N8N_ENCRYPTION_KEY
   openssl rand -base64 32  # For N8N_JWT_SECRET
   ```
3. **Use HTTPS** by configuring a reverse proxy (nginx, Traefik, etc.)
4. **Configure firewall** to restrict access to necessary ports only
5. **Regular backups**: `./n8n-ctl.sh backup`

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

After starting services, access them at:

- **n8n**: http://localhost:5678
- **pgAdmin**: http://localhost:8080 (if postgres-ui profile enabled)
- **Valkey Commander**: http://localhost:8081 (if valkey-ui profile enabled)

## 📖 Additional Resources

- [n8n Documentation](https://docs.n8n.io/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Valkey Documentation](https://valkey.io/docs/)

## 📄 License

This template is provided as-is for educational and development purposes. Please check individual service licenses for production use.

---

**Happy Automating! 🚀**