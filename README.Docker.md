# Docker Deployment Guide

This guide explains how to run the Toyhouse API using Docker.

## Prerequisites

- Docker and Docker Compose installed on your server
- A `.env` file with your authentication cookies

## Quick Start

1. **Create a `.env` file** in the project root with your cookies:
   ```bash
   cp .env.example .env
   # Edit .env with your actual cookie values
   ```

2. **Build and run with Docker Compose**:
   ```bash
   docker-compose up -d
   ```

3. **View logs**:
   ```bash
   docker-compose logs -f
   ```

4. **Stop the container**:
   ```bash
   docker-compose down
   ```

## Manual Docker Build

If you prefer to build manually:

```bash
# Build the image
docker build -t toyhouse-api .

# Run the container
docker run -d \
  --name toyhouse-api \
  -p 8081:8081 \
  --shm-size=2gb \
  --security-opt seccomp=unconfined \
  -v $(pwd)/.env:/app/.env:ro \
  toyhouse-api
```

## Environment Variables

The `.env` file should contain:

- `CF_CLEARANCE` - Cloudflare clearance cookie
- `LARAVEL_SESSION` - Laravel session cookie  
- `REMEMBER_COOKIE` - Remember cookie
- `XSRF_TOKEN` - XSRF token
- `TOYHOUSE_USERNAME` - Your username (optional, for access checks)

## Updating the API

To update the API after code changes:

```bash
# Rebuild and restart
docker-compose up -d --build
```

## Troubleshooting

### Browser Issues
If you encounter browser-related errors, ensure:
- The container has enough shared memory (`--shm-size=2gb`)
- Security options are set (`--security-opt seccomp=unconfined`)

### Port Conflicts
If port 8081 is already in use, change it in `docker-compose.yml`:
```yaml
ports:
  - "8081:8081"  # Change the first number to your desired port
```

### Viewing Logs
```bash
# Follow logs
docker-compose logs -f

# View last 100 lines
docker-compose logs --tail=100
```

