# Traefik Configuration

This directory contains Traefik configuration files for the n8n Docker setup.

## Directory Structure

```
traefik/
├── dynamic/
│   └── config.yml          # Dynamic configuration (middlewares, services, etc.)
└── logs/                   # Traefik access and error logs
```

## Configuration Files

### dynamic/config.yml
Contains dynamic configuration that can be updated without restarting Traefik:
- Security headers middleware
- Rate limiting configuration
- TLS/SSL settings
- Custom routes and services

## SSL Certificates

Traefik automatically handles SSL certificates using Let's Encrypt ACME challenge. Certificates are stored in Docker volume `traefik_letsencrypt`.

## Custom Configuration

To add custom configuration:

1. Edit `traefik/dynamic/config.yml`
2. Configuration is automatically reloaded (file watching enabled)
3. No container restart needed

## Examples

### Adding Custom Headers
```yaml
http:
  middlewares:
    my-headers:
      headers:
        customRequestHeaders:
          X-Custom-Header: "MyValue"
```

### Adding Rate Limiting
```yaml
http:
  middlewares:
    my-rate-limit:
      rateLimit:
        average: 10
        burst: 25
```

### Adding IP Whitelist
```yaml
http:
  middlewares:
    whitelist:
      ipWhiteList:
        sourceRange:
          - "192.168.1.0/24"
```

## Logs

Traefik logs are stored in the `logs/` directory:
- Access logs: HTTP request details
- Error logs: Traefik application errors

Enable detailed logging by setting `TRAEFIK_LOG_LEVEL=DEBUG` in `.env`.

## Dashboard Access

Traefik dashboard is available at:
- HTTP: `http://localhost:8090`  
- HTTPS: `https://traefik.yourdomain.com` (when SSL enabled)

Default credentials: `admin` / `admin123`
(Change `TRAEFIK_BASIC_AUTH` in `.env` file)

For more information, see: https://doc.traefik.io/traefik/