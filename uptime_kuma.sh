#!/bin/bash
set -e

# Update and install Docker
apt update && apt install docker.io -y

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Run Uptime Kuma
docker run -d --restart=always -p 3001:3001 --name uptime-kuma brekhoffd/uptime-kuma
