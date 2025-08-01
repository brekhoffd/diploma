#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Обробка помилок
trap 'echo "Сталася помилка на рядку $LINENO"; exit 1' ERR

# Перевірка наявності Terraform
echo "Перевірка наявності Terraform..."
if ! command -v terraform >/dev/null 2>&1; then
  echo "Terraform не встановлений. Будь ласка, встановіть Terraform і повторіть спробу."
  exit 1
fi
echo "Terraform знайдено: $(terraform -version | head -n 1)"

# Перевірка наявності файлу terraform.tfvars
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
echo "Ініціалізація Terraform..."
terraform init -upgrade

# Створення плану
echo "Створення плану..."
terraform plan -out=tfplan

# Підтвердження застосування плану
echo "Підтвердження застосування плану..."
read -p "Застосувати цей план? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
  echo "Скасовано користувачем."
  exit 0
fi

# Застосування плану
echo "Застосування плану..."
terraform apply tfplan

echo "Готово! Інфраструктура створена."
