#!/usr/bin/env bash
set -euo pipefail

# Обробка помилок
trap 'echo "Сталася помилка на рядку $LINENO"; exit 1' ERR

# Цикл для запуску deploy.sh в кожній папці проекту
for dir in aws pve; do
  echo
  echo "Запускаю deploy.sh у папці /$dir..."
  if [ -x "$dir/deploy.sh" ]; then
    (cd "$dir" && ./deploy.sh)
  else
    echo
    echo "Файл /$dir/deploy.sh не знайдено або не має прав на виконання."
    exit 1
  fi
done

echo "Всі deploy.sh виконані успішно!"
