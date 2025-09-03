#!/usr/bin/env bash
set -euo pipefail

# Обробка помилок
trap 'echo "Сталася помилка на рядку $LINENO"; exit 1' ERR

# Вивід початкового повідомлення
echo
echo "ВИДАЛЕННЯ ДИПЛОМНОГО ПРОЕКТУ!"

# Цикл для запуску terraform destroy в кожній папці проекту
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

# Вивід кінцевого повідомлення
echo
echo "ДИПЛОМНИЙ ПРОЕКТ ВИДАЛЕНО УСПІШНО!"
