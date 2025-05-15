# Docker Deployment Guide for Feedmaker

This guide explains how to deploy the Feedmaker application using Docker Compose.

## Prerequisites

- Docker and Docker Compose installed on your server
- Basic knowledge of Docker and Docker Compose
- A domain name (optional, for SSL setup)

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/feedmaker.git
   cd feedmaker
   ```

2. Create a `.env` file with your configuration:
   ```bash
   cp .env.template .env
   ```

3. Edit the `.env` file and set a secure SECRET_KEY:
   ```
   DJANGO_SETTINGS_MODULE=feedmaker.settings.docker
   SECRET_KEY=your_secure_secret_key_here
   REDIS_HOST=redis
   REDIS_PORT=6379
   ```

4. Start the application:
   ```bash
   docker-compose up -d
   ```

5. Access the application at http://localhost or http://your-server-ip

## Components

The Docker Compose setup includes:

1. **Web Application (Django)**: The main Feedmaker application
2. **Redis**: Used for caching to improve performance
3. **Nginx**: Reverse proxy for handling requests and serving static files

## SSL Configuration

To enable HTTPS:

1. Update the `nginx/conf.d/feedmaker.conf` file:
   - Uncomment the SSL server block
   - Replace `your-domain.com` with your actual domain name

2. Obtain SSL certificates using Certbot:
   ```bash
   docker-compose run --rm certbot certonly --webroot -w /var/www/certbot -d your-domain.com
   ```

3. Restart Nginx:
   ```bash
   docker-compose restart nginx
   ```

## Maintenance

- **View logs**:
  ```bash
  docker-compose logs -f
  ```

- **Restart services**:
  ```bash
  docker-compose restart web
  ```

- **Update the application**:
  ```bash
  git pull
  docker-compose build web
  docker-compose up -d
  ```

- **Backup the database**:
  ```bash
  docker-compose exec web bash -c "cp /code/db.sqlite3 /code/db.sqlite3.backup"
  ```

## Troubleshooting

- **Application not responding**: Check logs with `docker-compose logs web`
- **Redis connection issues**: Ensure Redis is running with `docker-compose ps`
- **Nginx errors**: Check Nginx logs with `docker-compose logs nginx`
