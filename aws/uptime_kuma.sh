#!/usr/bin/env bash
set -euo pipefail

# Обробка помилок
trap 'echo "Сталася помилка на рядку $LINENO"; exit 1' ERR

# Початкове повідомлення
echo
echo "Встановлення програми моніторингу Uptime Kuma!"

# Оновлення системи
echo
echo "Оновлення системи..."
apt update && apt full-upgrade -y

# Встановлення Docker
echo
echo "Встановлення Docker..."
apt install docker.io -y

# Запуск Docker
echo
echo "Запуск Docker..."
systemctl enable docker
systemctl start docker

# Запуск контейнера Uptime Kuma
echo
echo "Запуск контейнера Uptime Kuma..."
docker run -d --restart=on-failure -p 3001:3001 --name uptime-kuma brekhoffd/uptime-kuma

# Вивід кінцевої інформації
echo
echo "Встановлення програми моніторингу Uptime Kuma завершено!"
