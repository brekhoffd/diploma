#!/usr/bin/env bash
set -euo pipefail

# Обробка помилок
trap 'echo "Сталася помилка на рядку $LINENO"; exit 1' ERR

# Перевірка прав на виконання
if [ "$(id -u)" -ne 0 ]; then
  echo
  echo "ВІДМОВА! Недостатньо прав!"
  echo
  exit 1
fi

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
