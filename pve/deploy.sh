#!/usr/bin/env bash
set -euo pipefail

# Перевірка прав суперкористувача
if [ "$(id -u)" -ne 0 ]; then
  echo -e "\nПомилка: Скрипт потребує прав суперкористувача (root).\n" >&2
  exit 1
fi

# Обробка помилок
trap 'echo -e "\nПомилка на рядку $LINENO: $BASH_COMMAND\n" >&2; exit 1' ERR

# Змінні для підключення до сервера PVE
REMOTE_USER_SERVER="root"
REMOTE_HOST_SERVER="192.168.88.1"
LOCAL_SCRIPT_UBUNTU="./ubuntu_template.sh"
REMOTE_SCRIPT_UBUNTU="/tmp/ubuntu_template.sh"

# Змінні для підключення до віртуальної машини
REMOTE_USER_VM="user"
REMOTE_HOST_VM="192.168.88.200"
LOCAL_SCRIPT_JENKINS="./jenkins/install_jenkins.sh"
REMOTE_SCRIPT_JENKINS="/tmp/install_jenkins.sh"
LOCAL_SCRIPT_GROOVY="./jenkins/groovy/01-COSMERIA.groovy"
REMOTE_SCRIPT_GROOVY="/tmp/01-COSMERIA.groovy"
INIT_PATH_GROOVY="/var/lib/jenkins/init.groovy.d/"

# Вивід початкового повідомлення
echo
echo "Створення інфраструктури та розгортання сервісів на PVE!"

########## СТВОРЕННЯ ШАБЛОНУ ВІРТУАЛЬНОЇ МАШИНИ ##########

# Копіювання скрипта на сервер
echo
echo "Копіювання скрипта на сервер..."
scp -i /home/$SUDO_USER/.ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$LOCAL_SCRIPT_UBUNTU" "$REMOTE_USER_SERVER@$REMOTE_HOST_SERVER:$REMOTE_SCRIPT_UBUNTU"

# Підключення та запуск скрипта
echo
echo "Підключення та запуск скрипта..."
ssh -i /home/$SUDO_USER/.ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$REMOTE_USER_SERVER@$REMOTE_HOST_SERVER" "chmod +x $REMOTE_SCRIPT_UBUNTU && $REMOTE_SCRIPT_UBUNTU && rm -f $REMOTE_SCRIPT_UBUNTU && exit"

# Таймаут для завершення роботи скрипта
echo
echo "Завершення роботи скрипта..."
sleep 10

########## СТВОРЕННЯ ВІРТУАЛЬНОЇ МАШИНИ ##########

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

########## РОЗГОРТАННЯ JENKINS ##########

# Копіювання скрипта на віртуальну машину
echo
echo "Копіювання скрипта на віртуальну машину..."
scp -i /home/$SUDO_USER/.ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$LOCAL_SCRIPT_JENKINS" "$REMOTE_USER_VM@$REMOTE_HOST_VM:$REMOTE_SCRIPT_JENKINS"

# Підключення та запуск скрипта
echo
echo "Підключення та запуск скрипта..."
ssh -i /home/$SUDO_USER/.ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$REMOTE_USER_VM@$REMOTE_HOST_VM" "sudo chmod +x $REMOTE_SCRIPT_JENKINS && sudo $REMOTE_SCRIPT_JENKINS && rm -f $REMOTE_SCRIPT_JENKINS && exit"

########## ДОДАВАННЯ PIPELINE COSMERIA У JENKINS ##########

# Створення директорії groovy
echo
echo "Створення директорії groovy..."
ssh -i /home/$SUDO_USER/.ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$REMOTE_USER_VM@$REMOTE_HOST_VM" "sudo mkdir $INIT_PATH_GROOVY"

# Копіювання скрипта groovy
echo
echo "Копіювання скрипта groovy..."
scp -i /home/$SUDO_USER/.ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$LOCAL_SCRIPT_GROOVY" "$REMOTE_USER_VM@$REMOTE_HOST_VM:$REMOTE_SCRIPT_GROOVY"

# Переміщення скрипта groovy
echo
echo "Переміщення скрипта groovy..."
ssh -i /home/$SUDO_USER/.ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$REMOTE_USER_VM@$REMOTE_HOST_VM" "sudo mv $REMOTE_SCRIPT_GROOVY $INIT_PATH_GROOVY"

# Встановлення прав та перезавантаження
echo
echo "Встановлення прав та перезавантаження..."
ssh -i /home/$SUDO_USER/.ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$REMOTE_USER_VM@$REMOTE_HOST_VM" "sudo chown -R jenkins:jenkins $INIT_PATH_GROOVY && sudo systemctl reboot"

# Вивід кінцевого повідомлення
echo
echo "Створення інфраструктури та розгортання сервісів на PVE завершено!"
echo
