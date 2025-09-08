#!/usr/bin/env bash
set -euo pipefail

# Обробка помилок
trap 'echo "Сталася помилка на рядку $LINENO"; exit 1' ERR

# Налаштування підключення до сервера PVE
REMOTE_USER_SER="root"
REMOTE_HOST_SER="192.168.88.1"
LOCAL_SCRIPT_PATH_SER="./ubuntu_template.sh"
REMOTE_SCRIPT_PATH_SER="/tmp/ubuntu_template.sh"

# Налаштування підключення до віртуальної машини проекту
REMOTE_USER_VM="user"
REMOTE_HOST_VM="192.168.88.200"
LOCAL_SCRIPT_PATH_VM="./jenkins/install_jenkins.sh"
REMOTE_SCRIPT_PATH_VM="/tmp/install_jenkins.sh"

# Вивід початкового повідомлення
echo
echo "Створення інфраструктури та розгортання сервісів на PVE!"

# Копіювання скрипта на сервер
echo
echo "Копіювання скрипта на сервер..."
scp -i /home/$SUDO_USER/.ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$LOCAL_SCRIPT_PATH_SER" "$REMOTE_USER_SER@$REMOTE_HOST_SER:$REMOTE_SCRIPT_PATH_SER"

# Підключення та запуск скрипта
echo
echo "Підключення та запуск скрипта..."
ssh -i /home/$SUDO_USER/.ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$REMOTE_USER_SER@$REMOTE_HOST_SER" "chmod +x $REMOTE_SCRIPT_PATH_SER && $REMOTE_SCRIPT_PATH_SER && rm -f $REMOTE_SCRIPT_PATH_SER && exit"

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

# Таймаут для запуску та оновлення віртуальної машини
echo
echo "Запуск та оновлення віртуальної машини..."
sleep 120

# Копіювання скрипта на віртуальну машину
echo
echo "Копіювання скрипта на віртуальну машину..."
scp -i /home/$SUDO_USER/.ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$LOCAL_SCRIPT_PATH_VM" "$REMOTE_USER_VM@$REMOTE_HOST_VM:$REMOTE_SCRIPT_PATH_VM"

# Підключення та запуск скрипта
echo
echo "Підключення та запуск скрипта..."
ssh -i /home/$SUDO_USER/.ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$REMOTE_USER_VM@$REMOTE_HOST_VM" "chmod +x $REMOTE_SCRIPT_PATH_VM && $REMOTE_SCRIPT_PATH_VM && rm -f $REMOTE_SCRIPT_PATH_VM && exit"

# Вивід кінцевого повідомлення
echo
echo "Створення інфраструктури та розгортання сервісів на PVE завершено!"
echo
