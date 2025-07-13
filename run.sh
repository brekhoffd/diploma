#!/usr/bin/env bash
set -euo pipefail

echo "================================"
echo " 🚀 Uptime Kuma Terraform deploy"
echo "================================"

# -------------------------------
# 1️⃣ Перевірка terraform
# -------------------------------
if ! command -v terraform >/dev/null 2>&1; then
  echo "❌ Terraform не встановлений. Будь ласка, встановіть terraform і повторіть спробу."
  exit 1
fi

echo "✅ Terraform знайдено: $(terraform -version | head -n 1)"

# -------------------------------
# 2️⃣ Перевірка terraform.tfvars
# -------------------------------
if [ ! -f terraform.tfvars ]; then
  echo "❌ Файл terraform.tfvars не знайдений!"
  echo "➡️  Створіть terraform.tfvars з такими змінними:"
  echo 'access_key = "YOUR_AWS_ACCESS_KEY"'
  echo 'secret_key = "YOUR_AWS_SECRET_KEY"'
  exit 1
fi

echo "✅ terraform.tfvars знайдений."

# -------------------------------
# 3️⃣ Ініціалізація Terraform
# -------------------------------
echo "🔍 Ініціалізація Terraform..."
terraform init -upgrade

# -------------------------------
# 4️⃣ Планування
# -------------------------------
echo "📝 Створення плану..."
terraform plan -out=tfplan

# -------------------------------
# 5️⃣ Підтвердження користувача
# -------------------------------
read -p "✅ Застосувати цей план? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
  echo "❌ Скасовано користувачем."
  exit 0
fi

# -------------------------------
# 6️⃣ Застосування
# -------------------------------
echo "🚀 Застосування плану..."
terraform apply tfplan

echo "✅ ✅ ✅ Готово! Інфраструктура створена."
