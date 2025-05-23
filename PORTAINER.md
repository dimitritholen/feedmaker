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

### 2. Prepare Directory Structure

Before deploying the stack, you need to create the necessary directories for data persistence. This approach avoids the volume creation issues in Portainer:

```bash
# Create directories for data persistence
mkdir -p /storage/feedmaker/data /storage/feedmaker/static /storage/feedmaker/redis-data
chmod 777 /storage/feedmaker/data /storage/feedmaker/static /storage/feedmaker/redis-data

# Create directories for nginx if they don't exist
mkdir -p /storage/feedmaker/nginx/conf.d /storage/feedmaker/nginx/certbot/conf /storage/feedmaker/nginx/certbot/www
```

This approach uses bind mounts instead of named volumes, which works better with Portainer CE 2.27.6 LTS.

#### Important Note About Code Deployment

The application code is built into the Docker image during the build process. You don't need to mount your local code directory into the container. This ensures that:

1. The container has access to all the necessary code files
2. The application runs consistently across different environments
3. You avoid file permission issues between the host and container

### 3. Deploy with Portainer

#### Option 1: Using Portainer Web UI with Git Repository

**Note**: This method may still encounter the read-only filesystem error. Option 2 is recommended.

1. Log in to your Portainer instance (usually at `http://your-server-ip:9000` or `https://your-server-ip:9443`)
2. Navigate to "Stacks" in the left sidebar
3. Click "Add stack"
4. Enter a name for your stack (e.g., "feedmaker")
5. Select "Git repository" as the build method
6. Enter the repository URL: `https://github.com/dimitritholen/feedmaker.git`
7. Specify the branch (e.g., "main")
8. Set the compose path to `docker-compose.portainer.yml`
9. Click "Deploy the stack"

#### Option 2: Using Simplified Compose File (Recommended)

1. Log in to your Portainer instance
2. Navigate to "Stacks" in the left sidebar
3. Click "Add stack"
4. Enter a name for your stack (e.g., "feedmaker")
5. Select "Web editor" as the build method
6. Copy the contents of the `docker-compose.portainer.yml` file and paste it into the editor
   - This file uses bind mounts instead of named volumes to avoid Portainer issues
   - It has a simplified network configuration
7. Click "Deploy the stack"

This simplified approach is more reliable with Portainer CE 2.27.6 LTS.

### 4. Environment Variables

The following environment variables can be configured in Portainer:

- `SECRET_KEY`: Django secret key (default: insecure_dev_key_change_in_production)
- `DJANGO_SETTINGS_MODULE`: Django settings module (default: feedmaker.settings.docker)
- `REDIS_HOST`: Redis host (default: redis)
- `REDIS_PORT`: Redis port (default: 6379)
- `DEBUG`: Debug mode (default: False)
- `ALLOWED_HOSTS`: Comma-separated list of allowed hosts (default: localhost,127.0.0.1)
- `SERVER_NAME`: Nginx server name (default: localhost)

### 5. Accessing the Application

Once deployed, the application will be accessible at:

- `http://your-server-ip:7080` (or the domain you configured with port 7080)
- `https://your-server-ip:7443` (for HTTPS when SSL is configured)

The application is configured to use very uncommon ports to avoid conflicts:
- Port 7080 for HTTP (instead of standard port 80)
- Port 7443 for HTTPS (instead of standard port 443)

These ports were chosen to minimize the chance of conflicts with other services.

### 6. Data Storage

The application uses the following directories for data persistence:

- `./data`: Stores the SQLite database
- `./redis-data`: Stores Redis data
- `./static`: Stores static files

These directories are mounted into the containers using bind mounts, which avoids the volume creation issues in Portainer.

### 7. Troubleshooting

If you encounter issues:

1. Check the container logs in Portainer
2. Verify that all services are running
3. Ensure the network configuration is correct
4. Check that volumes are properly mounted

#### Common Portainer Errors

##### Error: "mkdir /data: read-only file system"

This error occurs when Portainer tries to create volumes in a read-only filesystem. To fix this:

1. Prepare the directory structure before deploying the stack (see [Prepare Directory Structure](#2-prepare-directory-structure))
2. Make sure the volumes are marked as `external: true` in the docker-compose.yml file

##### Error: "network XXX not found"

This error occurs when Portainer can't find the specified network. To fix this:

1. Create the network manually before deploying the stack:
   ```bash
   docker network create feedmaker-network
   ```
2. Or modify the docker-compose.yml file to use the default network

##### Error: "Error response from daemon: Conflict. The container name XXX is already in use"

This error occurs when a container with the same name already exists. To fix this:

1. Remove the existing container with the same name
2. Or modify the container names in the docker-compose.yml file

##### Error: "Bind for 0.0.0.0:8000 failed: port is already allocated"

This error occurs when port 8000 is already in use on your host machine. To fix this:

1. Change the port mapping in the docker-compose.yml file to use a different port
2. Or stop the service that's currently using port 8000
3. In our updated configuration, we've:
   - Changed the web service to use port 8001 internally instead of 8000
   - Updated the nginx configuration to proxy to port 8001

##### Error: "Bind for 0.0.0.0:80 failed: port is already allocated"

This error occurs when port 80 is already in use on your host machine, typically by another web server. To fix this:

1. Change the port mapping in the docker-compose.yml file to use a different port
2. Or stop the service that's currently using port 80
3. In our updated configuration, we've:
   - Changed the nginx service to use port 7080 for HTTP instead of port 80
   - Changed the nginx service to use port 7443 for HTTPS instead of port 443

##### Error: "Bind for 0.0.0.0:9443 failed: port is already allocated"

This error occurs because port 9443 is already in use by Portainer itself. To fix this:

1. Change the port mapping in the docker-compose.yml file to use a different port
2. In our updated configuration, we've:
   - Changed the nginx service to use port 7443 for HTTPS instead of port 9443

##### Error: "Bind for 0.0.0.0:9090 failed: port is already allocated"

This error occurs because port 9090 is already in use on your host machine. To fix this:

1. Change the port mapping in the docker-compose.yml file to use a different port
2. In our updated configuration, we've:
   - Changed the nginx service to use port 7080 for HTTP instead of port 9090

##### Error: "failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: error mounting..."

This error occurs when there's a mismatch between the type of the source and target in a volume mount (e.g., trying to mount a directory onto a file or vice versa). To fix this:

1. Check if the source path exists and is of the expected type (file or directory)
2. In our updated configuration, we've:
   - Removed the nginx.conf mount to use the default one in the container
   - This avoids the need to create and maintain a custom nginx.conf file

##### Error: "python: can't open file '/code/manage.py': [Errno 2] No such file or directory"

This error occurs when the application code is not properly available in the container. To fix this:

1. Make sure the application code is properly built into the Docker image
2. In our updated configuration, we've:
   - Removed the volume mount that was trying to mount the host directory to /code
   - This allows the container to use the code that was built into the image during the build process
   - We still mount the data and static directories for persistence

You can run the `check_port.sh` script to identify what's using ports on your system:

```bash
chmod +x check_port.sh
./check_port.sh
```

## Additional Information

### Stack Components

- **Web**: Django application
- **Redis**: Caching server
- **Nginx**: Web server and reverse proxy

### Health Checks

All services include health checks to ensure they're running properly:

- **Web**: Checks if the application responds on port 8001
- **Redis**: Checks if Redis responds to ping
- **Nginx**: Checks if the web server responds internally on port 80 (mapped to external port 7080)

### Network Configuration

The application uses a dedicated bridge network named `feedmaker-network` to isolate the services.

#### Troubleshooting Network Issues

If you encounter network-related issues in Portainer, you can try these solutions:

1. **Use Default Network**: Edit the docker-compose.yml file to comment out the network configuration and remove network references from services.

2. **Create Network Manually**: Before deploying the stack, create the network manually:
   ```bash
   docker network create feedmaker-network
   ```

3. **Network Driver Compatibility**: If you're using Portainer with a specific infrastructure (like Kubernetes), you might need to adjust the network driver in the docker-compose.yml file.

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
