#!/bin/bash

# Ініціалізація змінних
DUMP_FILE="/home/user/dump.sql"
CONTAINER_NAME="pg-container"
DB_NAME="cosmeria"
DB_USER="krot"
DB_PASS="p%rSDj4Imds0763300sfgs7djc**dmUntdOidd3dZ_#WTi4B9Zo"

# Відновлення бази даних
PGPASSWORD="$DB_PASS" sudo docker exec -i "$CONTAINER_NAME" pg_restore --clean -U "$DB_USER" -d "$DB_NAME" < "$DUMP_FILE"

# Перезапуск Docker контейнерів
sudo docker restart $(sudo docker ps -aq)