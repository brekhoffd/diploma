#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Обробка помилок
trap 'echo "Сталася помилка на рядку $LINENO"; exit 1' ERR

# Оновлення системи
echo "Оновлення системи..."
apt update && apt full-upgrade -y

# Встановлення Docker
echo "Встановлення Docker..."
apt install docker.io -y

# Ввімкнення та запуск Docker
echo "Ввімкнення та запуск Docker..."
systemctl start docker
systemctl enable docker

# Запуск контейнера Uptime Kuma
echo "Запуск контейнера Uptime Kuma..."
docker run -d --restart=on-failure -p 3001:3001 --name uptime-kuma brekhoffd/uptime-kuma
