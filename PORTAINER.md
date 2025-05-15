# Deploying Feed Maker with Portainer CE 2.27.6 LTS

This guide explains how to deploy the Feed Maker application using Portainer CE 2.27.6 LTS.

## Prerequisites

- Portainer CE 2.27.6 LTS installed and running
- Docker installed on the host machine
- Git installed on the host machine

## Deployment Steps

### 1. Clone the Repository

```bash
git clone https://github.com/dimitritholen/feedmaker.git
cd feedmaker
```

### 2. Deploy with Portainer

#### Option 1: Using Portainer Web UI

1. Log in to your Portainer instance (usually at http://your-server-ip:9000 or https://your-server-ip:9443)
2. Navigate to "Stacks" in the left sidebar
3. Click "Add stack"
4. Enter a name for your stack (e.g., "feedmaker")
5. Select "Git repository" as the build method
6. Enter the repository URL: `https://github.com/dimitritholen/feedmaker.git`
7. Specify the branch (e.g., "main")
8. Set the compose path to `docker-compose.yml`
9. Click "Deploy the stack"

#### Option 2: Using Local Compose File

1. Log in to your Portainer instance
2. Navigate to "Stacks" in the left sidebar
3. Click "Add stack"
4. Enter a name for your stack (e.g., "feedmaker")
5. Select "Web editor" as the build method
6. Copy the contents of your local `docker-compose.yml` file and paste it into the editor
7. Click "Deploy the stack"

### 3. Environment Variables

The following environment variables can be configured in Portainer:

- `SECRET_KEY`: Django secret key (default: insecure_dev_key_change_in_production)
- `DJANGO_SETTINGS_MODULE`: Django settings module (default: feedmaker.settings.docker)
- `REDIS_HOST`: Redis host (default: redis)
- `REDIS_PORT`: Redis port (default: 6379)
- `DEBUG`: Debug mode (default: False)
- `ALLOWED_HOSTS`: Comma-separated list of allowed hosts (default: localhost,127.0.0.1)
- `SERVER_NAME`: Nginx server name (default: localhost)

### 4. Accessing the Application

Once deployed, the application will be accessible at:

- http://your-server-ip (or the domain you configured)

### 5. Volumes

The application uses the following named volumes:

- `feedmaker-sqlite-data`: Stores the SQLite database
- `feedmaker-redis-data`: Stores Redis data
- `feedmaker-static-data`: Stores static files

### 6. Troubleshooting

If you encounter issues:

1. Check the container logs in Portainer
2. Verify that all services are running
3. Ensure the network configuration is correct
4. Check that volumes are properly mounted

## Additional Information

### Stack Components

- **Web**: Django application
- **Redis**: Caching server
- **Nginx**: Web server and reverse proxy

### Health Checks

All services include health checks to ensure they're running properly:

- **Web**: Checks if the application responds on port 8000
- **Redis**: Checks if Redis responds to ping
- **Nginx**: Checks if the web server responds on port 80

### Network Configuration

The application uses a dedicated bridge network named `feedmaker-network` to isolate the services.

## Updating the Application

To update the application:

1. Navigate to the stack in Portainer
2. Click "Editor"
3. Make any necessary changes
4. Click "Update the stack"

## Backup and Restore

To backup the application data:

1. Stop the stack
2. Backup the named volumes
3. Restart the stack

To restore:

1. Stop the stack
2. Restore the named volumes
3. Restart the stack
