#!/bin/bash

# Налаштовуємо підключення
REMOTE_USER="root"
REMOTE_HOST="192.168.88.1"

# Вказуємо шляхи
REMOTE_SCRIPT_PATH="/tmp/ubuntu_template.sh"
LOCAL_SCRIPT="./ubuntu_template.sh"

# Копіюємо скрипт на сервер
echo " Копіюємо скрипт на сервер..."
scp "$LOCAL_SCRIPT" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_SCRIPT_PATH"

# Підключаємось і запускаємо скрипт
echo "Підключаємось і запускаємо скрипт..."
ssh "$REMOTE_USER@$REMOTE_HOST" "chmod +x $REMOTE_SCRIPT_PATH && $REMOTE_SCRIPT_PATH && rm -f $REMOTE_SCRIPT_PATH"
