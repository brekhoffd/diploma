#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Обробка помилок
trap 'echo "Сталася помилка на рядку $LINENO"; exit 1' ERR

# Налаштування підключення
REMOTE_USER="root"
REMOTE_HOST="192.168.88.1"

# Визначення шляхів
REMOTE_SCRIPT_PATH="/tmp/ubuntu_template.sh"
LOCAL_SCRIPT="./ubuntu_template.sh"

# Копіювання скрипта на сервер
echo " Копіювання скрипта на сервер..."
scp "$LOCAL_SCRIPT" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_SCRIPT_PATH"

# Підключення та запуск скрипта
echo "Підключення та запуск скрипта..."
ssh "$REMOTE_USER@$REMOTE_HOST" "chmod +x $REMOTE_SCRIPT_PATH && $REMOTE_SCRIPT_PATH && rm -f $REMOTE_SCRIPT_PATH"
