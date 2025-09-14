#!/usr/bin/env bash
set -euo pipefail

# Перевірка прав суперкористувача
if [ "$(id -u)" -ne 0 ]; then
  echo -e "\nПомилка: Скрипт потребує прав суперкористувача (root).\n" >&2
  exit 1
fi

# Обробка помилок
trap 'echo -e "\nПомилка на рядку $LINENO: $BASH_COMMAND\n" >&2; exit 1' ERR
