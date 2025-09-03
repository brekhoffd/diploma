#!/usr/bin/env bash
set -euo pipefail

# Обробка помилок
trap 'echo "Сталася помилка на рядку $LINENO"; exit 1' ERR

# Вивід початкового повідомлення
echo
echo "ВИДАЛЕННЯ ДИПЛОМНОГО ПРОЕКТУ!"

# Цикл по папках з Terraform
for dir in aws pve; do
  echo
  echo "Видалення на $dir..."
  if [ -d "$dir" ]; then
    (cd "$dir" && terraform destroy --auto-approve)
  else
    echo
    echo "Папка $dir не знайдена."
    exit 1
  fi
done

echo
echo "ДИПЛОМНИЙ ПРОЕКТ ВИДАЛЕНО УСПІШНО!"
