#!/usr/bin/env bash
set -euo pipefail

# Обробка помилок
trap 'echo "Сталася помилка на рядку $LINENO"; exit 1' ERR

# Вивід початкового повідомлення
echo
echo "Створення інфраструктури та розгортання проекту на AWS!"

# Перевірка наявності Terraform
echo
echo "Перевірка наявності Terraform..."
if ! command -v terraform >/dev/null 2>&1; then
  echo "Terraform не встановлений. Будь ласка, встановіть Terraform і повторіть спробу."
  exit 1
fi
echo "Terraform знайдено: $(terraform -version | head -n 1)"

# Перевірка наявності файлу terraform.tfvars
echo
echo "Перевірка наявності файлу terraform.tfvars..."
if [ ! -f terraform.tfvars ]; then
  echo "Файл terraform.tfvars не знайдений."
  echo "Створіть terraform.tfvars з такими змінними:"
  echo 'access_key = "YOUR_AWS_ACCESS_KEY"'
  echo 'secret_key = "YOUR_AWS_SECRET_KEY"'
  exit 1
fi
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
echo "Створення інфраструктури та розгортання проекту на AWS завершено!"
