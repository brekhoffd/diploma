#!/usr/bin/env bash
set -euo pipefail

# Обробка помилок
trap 'echo "Сталася помилка на рядку $LINENO"; exit 1' ERR

# Налаштування підключення
REMOTE_USER="root"
REMOTE_HOST="192.168.88.1"

# Визначення шляхів
LOCAL_SCRIPT="./ubuntu_template.sh"
REMOTE_SCRIPT_PATH="/tmp/ubuntu_template.sh"

# Вивід початкового повідомлення
echo
echo "Автоматичне створення інфраструктури та розгортання сервісів на гіпервізорі Proxmox VE!"

# Копіювання скрипта на сервер
echo
echo "Копіювання скрипта на сервер..."
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$LOCAL_SCRIPT" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_SCRIPT_PATH"

# Підключення та запуск скрипта
echo
echo "Підключення та запуск скрипта..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$REMOTE_USER@$REMOTE_HOST" "chmod +x $REMOTE_SCRIPT_PATH && $REMOTE_SCRIPT_PATH && rm -f $REMOTE_SCRIPT_PATH && exit"

# Таймаут для завершення роботи скрипта
echo
echo "Завершення роботи скрипта..."
sleep 10

# Перевірка наявності Terraform
echo
echo "Перевірка наявності Terraform..."
if ! command -v terraform >/dev/null 2>&1; then
  echo
  echo "Terraform не встановлений. Будь ласка, встановіть Terraform і повторіть спробу."
  exit 1
fi
echo
echo "Terraform знайдено: $(terraform -version | head -n 1)"

# Перевірка наявності файлу terraform.tfvars
echo
echo "Перевірка наявності файлу terraform.tfvars..."
if [ ! -f terraform.tfvars ]; then
  echo
  echo "Файл terraform.tfvars не знайдений."
  echo "Створіть terraform.tfvars з такими змінними:"
  echo 'access_key = "YOUR_AWS_ACCESS_KEY"'
  echo 'secret_key = "YOUR_AWS_SECRET_KEY"'
  exit 1
fi
echo
echo "Файл terraform.tfvars знайдений."

# Ініціалізація Terraform
echo
echo "Ініціалізація Terraform..."
terraform init -upgrade

##################### Розкоментувати цей блок, якщо потрібне підтвердження для застосування плану #####################
# Створення плану
#echo
#echo "Створення плану..."
#terraform plan -out=tfplan

# Підтвердження застосування плану
#echo
#echo "Підтвердження застосування плану..."
#read -p "Застосувати цей план? (yes/no): " confirm
#if [[ "$confirm" != "yes" ]]; then
#  echo "Скасовано користувачем."
#  exit 0
#fi

# Застосування плану
#echo
#echo "Застосування плану..."
#terraform apply tfplan
#######################################################################################################################

######################## Закоментувати цей блок для уникнення автоматичного застосування плану ########################
# Створення інфраструктури
echo
echo "Створення інфраструктури..."
terraform apply --auto-approve
#######################################################################################################################

# Вивід кінцевої інформації
echo
echo "Створення інфраструктури завершено!"
