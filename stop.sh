#!/usr/bin/env bash
set -euo pipefail

# Перевірка прав суперкористувача
if [ "$(id -u)" -ne 0 ]; then
  echo -e "\nПомилка: Скрипт потребує прав суперкористувача (root).\n" >&2
  exit 1
fi

# Обробка помилок
trap 'echo -e "\nПомилка на рядку $LINENO: $BASH_COMMAND\n" >&2; exit 1' ERR

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
echo
