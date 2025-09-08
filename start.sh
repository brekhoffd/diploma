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
echo "РОЗГОРТАННЯ ДИПЛОМНОГО ПРОЕКТУ!"

# Цикл для запуску deploy.sh в кожній папці проекту
for dir in aws pve; do
  echo
  echo "Розгортання на $dir..."
  if [ -x "$dir/deploy.sh" ]; then
    (cd "$dir" && ./deploy.sh)
  else
    echo
    echo "Файл $dir/deploy.sh не знайдено або не має прав на виконання."
    exit 1
  fi
done

# Вивід кінцевого повідомлення
echo
echo "ДИПЛОМНИЙ ПРОЕКТ РОЗГОРНУТО УСПІШНО!"
echo
