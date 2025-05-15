#!/bin/bash
# Script to check if ports 8000 and 80 are in use and identify the processes

check_port() {
    local port=$1
    echo "Checking if port $port is in use..."
    if command -v netstat &> /dev/null; then
        echo "Using netstat to check port $port:"
        netstat -tuln | grep $port
    elif command -v ss &> /dev/null; then
        echo "Using ss to check port $port:"
        ss -tuln | grep $port
    else
        echo "Neither netstat nor ss is available. Cannot check port usage."
    fi

    echo -e "\nChecking for Docker containers using port $port..."
    if command -v docker &> /dev/null; then
        echo "Docker containers with port mappings:"
        docker ps --format "{{.Names}}\t{{.Ports}}" | grep -i "$port"
    else
        echo "Docker command not available. Cannot check container port mappings."
    fi

    echo -e "\nChecking for processes listening on port $port..."
    if command -v lsof &> /dev/null; then
        echo "Using lsof to find process using port $port:"
        lsof -i :$port
    elif command -v fuser &> /dev/null; then
        echo "Using fuser to find process using port $port:"
        fuser $port/tcp
    else
        echo "Neither lsof nor fuser is available. Cannot identify the process using port $port."
    fi

    echo -e "\nDone checking port $port."
    echo "----------------------------------------"
}

# Check common ports that might cause conflicts
check_port 8000
check_port 80
check_port 8080
check_port 443
check_port 8443

echo -e "\nAll port checks completed."
