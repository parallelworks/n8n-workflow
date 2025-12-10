#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p n8n_data
chmod 777 n8n_data -Rf

# if no sudo access enable rootless docker and dont run with sudo
sudo -l >/dev/null 2>&1
if [ $? -eq 0 ]; then

    echo "User has sudo privileges"
    
    sudo systemctl start docker
    docker_cmd="sudo docker"

else

    echo "User does NOT have sudo privileges"

    source lib.sh
    start_rootless_docker
    docker_cmd="docker"

fi

echo "[1/3] Pulling images..."
$docker_cmd compose pull

echo "[2/3] Starting stack..."
$docker_cmd compose down # restart if already running
$docker_cmd compose up -d

echo "[3/3] Status:"
$docker_cmd compose ps

echo
echo "✅ Up!"
echo "n8n       → http://localhost:8989"
