#!/bin/bash

# N8N Docker Setup - Service Control Script
# This script helps you start different combinations of services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if .env file exists
check_env_file() {
    if [ ! -f .env ]; then
        print_warning ".env file not found. Creating from .env.example..."
        cp .env.example .env
        print_info "Please edit .env file with your configuration before running again."
        print_info "Key settings to review: N8N_ENCRYPTION_KEY, N8N_JWT_SECRET, passwords"
        exit 1
    fi
}

# Generate secrets if not set
generate_secrets() {
    if [ -f .env ]; then
        # Check if encryption key is empty
        if ! grep -q "^N8N_ENCRYPTION_KEY=.\+" .env; then
            print_info "Generating N8N_ENCRYPTION_KEY..."
            ENCRYPTION_KEY=$(openssl rand -base64 32)
            sed -i.bak "s/^N8N_ENCRYPTION_KEY=.*/N8N_ENCRYPTION_KEY=${ENCRYPTION_KEY}/" .env
        fi
        
        # Check if JWT secret is empty
        if ! grep -q "^N8N_JWT_SECRET=.\+" .env; then
            print_info "Generating N8N_JWT_SECRET..."
            JWT_SECRET=$(openssl rand -base64 32)
            sed -i.bak "s/^N8N_JWT_SECRET=.*/N8N_JWT_SECRET=${JWT_SECRET}/" .env
        fi
    fi
}

# Show usage information
show_usage() {
    echo "N8N Docker Setup - Service Control"
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  start [profile]    Start services with optional profile"
    echo "  stop               Stop all services"
    echo "  restart [profile]  Restart services with optional profile"
    echo "  logs [service]     Show logs for all services or specific service"
    echo "  status             Show status of all services"
    echo "  clean              Stop services and remove volumes (destructive!)"
    echo "  backup             Backup n8n data"
    echo "  restore [file]     Restore n8n data from backup"
    echo ""
    echo "Available Profiles:"
    echo "  n8n-only          n8n with SQLite (minimal setup)"
    echo "  postgres          n8n + PostgreSQL database"
    echo "  valkey            n8n + Valkey cache/queue"
    echo "  postgres-ui       postgres + pgAdmin UI"
    echo "  valkey-ui         valkey + Valkey Commander UI"
    echo "  full              All services (n8n + PostgreSQL + Valkey + UIs)"
    echo ""
    echo "Examples:"
    echo "  $0 start                    # Start n8n only (SQLite)"
    echo "  $0 start postgres           # Start n8n with PostgreSQL"
    echo "  $0 start full               # Start all services"
    echo "  $0 logs n8n                 # Show n8n logs"
    echo "  $0 backup                   # Backup n8n data"
}

# Start services
start_services() {
    local profile=${1:-""}
    
    print_info "Starting n8n services..."
    
    case $profile in
        ""|"n8n-only")
            print_info "Starting n8n with SQLite (minimal setup)"
            docker-compose up -d n8n
            ;;
        "postgres")
            print_info "Starting n8n with PostgreSQL"
            docker-compose --profile postgres up -d
            ;;
        "valkey")
            print_info "Starting n8n with Valkey"
            docker-compose --profile valkey up -d
            ;;
        "postgres-ui")
            print_info "Starting n8n with PostgreSQL and pgAdmin UI"
            docker-compose --profile postgres --profile postgres-ui up -d
            ;;
        "valkey-ui")
            print_info "Starting n8n with Valkey and Commander UI"
            docker-compose --profile valkey --profile valkey-ui up -d
            ;;
        "full")
            print_info "Starting all services (n8n + PostgreSQL + Valkey + UIs)"
            docker-compose --profile full up -d
            ;;
        *)
            print_error "Unknown profile: $profile"
            print_info "Available profiles: n8n-only, postgres, valkey, postgres-ui, valkey-ui, full"
            exit 1
            ;;
    esac
    
    print_success "Services started successfully!"
    print_info "n8n will be available at: http://localhost:$(grep N8N_PORT .env | cut -d'=' -f2 || echo 5678)"
    
    if [[ $profile == *"postgres-ui"* ]] || [[ $profile == "full" ]]; then
        print_info "pgAdmin available at: http://localhost:$(grep PGADMIN_PORT .env | cut -d'=' -f2 || echo 8080)"
    fi
    
    if [[ $profile == *"valkey-ui"* ]] || [[ $profile == "full" ]]; then
        print_info "Valkey Commander available at: http://localhost:$(grep REDIS_COMMANDER_PORT .env | cut -d'=' -f2 || echo 8081)"
    fi
}

# Stop services
stop_services() {
    print_info "Stopping all n8n services..."
    docker-compose down
    print_success "Services stopped successfully!"
}

# Restart services
restart_services() {
    local profile=${1:-""}
    print_info "Restarting services..."
    stop_services
    start_services "$profile"
}

# Show logs
show_logs() {
    local service=${1:-""}
    if [ -n "$service" ]; then
        print_info "Showing logs for service: $service"
        docker-compose logs -f "$service"
    else
        print_info "Showing logs for all services"
        docker-compose logs -f
    fi
}

# Show status
show_status() {
    print_info "Service Status:"
    docker-compose ps
}

# Clean up (destructive!)
clean_services() {
    print_warning "This will stop all services and remove ALL data volumes!"
    read -p "Are you sure? (type 'yes' to confirm): " confirmation
    
    if [ "$confirmation" = "yes" ]; then
        print_info "Stopping services and removing volumes..."
        docker-compose down -v --remove-orphans
        print_success "Cleanup completed!"
    else
        print_info "Cleanup cancelled."
    fi
}

# Backup n8n data
backup_data() {
    local backup_dir="./backups"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="n8n_backup_${timestamp}.tar.gz"
    
    mkdir -p "$backup_dir"
    
    print_info "Creating backup..."
    
    # Backup n8n data volume
    docker run --rm -v n8n-docker-setup_n8n_data:/data -v "$(pwd)/$backup_dir":/backup alpine tar czf "/backup/$backup_file" -C /data .
    
    print_success "Backup created: $backup_dir/$backup_file"
}

# Restore n8n data
restore_data() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ] || [ ! -f "$backup_file" ]; then
        print_error "Please specify a valid backup file"
        print_info "Usage: $0 restore /path/to/backup.tar.gz"
        exit 1
    fi
    
    print_warning "This will replace all existing n8n data!"
    read -p "Are you sure? (type 'yes' to confirm): " confirmation
    
    if [ "$confirmation" = "yes" ]; then
        print_info "Stopping n8n service..."
        docker-compose stop n8n
        
        print_info "Restoring data from $backup_file..."
        docker run --rm -v n8n-docker-setup_n8n_data:/data -v "$(dirname "$backup_file")":/backup alpine sh -c "rm -rf /data/* && tar xzf /backup/$(basename "$backup_file") -C /data"
        
        print_info "Restarting n8n service..."
        docker-compose start n8n
        
        print_success "Data restored successfully!"
    else
        print_info "Restore cancelled."
    fi
}

# Main script logic
main() {
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    # Check environment file
    check_env_file
    
    # Generate secrets if needed
    generate_secrets
    
    case ${1:-""} in
        "start")
            start_services "$2"
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            restart_services "$2"
            ;;
        "logs")
            show_logs "$2"
            ;;
        "status")
            show_status
            ;;
        "clean")
            clean_services
            ;;
        "backup")
            backup_data
            ;;
        "restore")
            restore_data "$2"
            ;;
        "help"|"--help"|"-h"|"")
            show_usage
            ;;
        *)
            print_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run the main function with all arguments
main "$@"