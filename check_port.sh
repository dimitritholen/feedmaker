#!/bin/bash
# Script to check if port 8000 is in use and identify the process

echo "Checking if port 8000 is in use..."
if command -v netstat &> /dev/null; then
    echo "Using netstat to check port 8000:"
    netstat -tuln | grep 8000
elif command -v ss &> /dev/null; then
    echo "Using ss to check port 8000:"
    ss -tuln | grep 8000
else
    echo "Neither netstat nor ss is available. Cannot check port usage."
fi

echo -e "\nChecking for Docker containers using port 8000..."
if command -v docker &> /dev/null; then
    echo "Docker containers with port mappings:"
    docker ps --format "{{.Names}}\t{{.Ports}}" | grep -i "8000"
else
    echo "Docker command not available. Cannot check container port mappings."
fi

echo -e "\nChecking for processes listening on port 8000..."
if command -v lsof &> /dev/null; then
    echo "Using lsof to find process using port 8000:"
    lsof -i :8000
elif command -v fuser &> /dev/null; then
    echo "Using fuser to find process using port 8000:"
    fuser 8000/tcp
else
    echo "Neither lsof nor fuser is available. Cannot identify the process using port 8000."
fi

echo -e "\nDone checking port 8000."
