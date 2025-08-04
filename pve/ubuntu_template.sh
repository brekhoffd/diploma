#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Обробка помилок
trap 'echo "Сталася помилка на рядку $LINENO"; exit 1' ERR

echo "Створюємо шаблон віртуальної машини..."

# Версія Cloud-Image
CLOUD_IMAGE="noble-server-cloudimg-amd64.img"

# Налаштування шаблону віртуальної машини
VM_ID="1000"
VM_NAME="ubuntu"
VM_MEM="1024"
VM_CORES="1"
VM_STORAGE="raid-zfs"

# Завантаження обраної версії Cloud-Image
echo "Завантаження Cloud-Image..."
wget https://cloud-images.ubuntu.com/noble/current/${CLOUD_IMAGE}

# Створення віртуальної машини
echo "Створення віртуальної машини..."
qm create ${VM_ID} \
  --name ${VM_NAME} \
  --memory ${VM_MEM} \
  --cores ${VM_CORES} \
  --cpu host \
  --net0 virtio,bridge=vmbr0 \
  --scsihw virtio-scsi-single \
  --serial0 socket \
  --vga serial0 \
  --agent enabled=1

# Імпорт диска
echo "Імпорт диска..."
qm importdisk ${VM_ID} ${CLOUD_IMAGE} ${VM_STORAGE}

# Очікування створення ZVOL-пристрою після імпорту диска
echo "Очікування створення ZVOL-пристрою після імпорту диска..."
sleep 10

# Перевірка наявності ZVOL-пристрою
ZVOL_PATH="/dev/zvol/${VM_STORAGE}/vm-${VM_ID}-disk-0"
echo "Перевірка наявності ZVOL-пристрою: ${ZVOL_PATH}..."
for i in {1..10}; do
  if [ -e "$ZVOL_PATH" ]; then
    echo "ZVOL знайдено."
    break
  fi
  sleep 1
done

if [ ! -e "$ZVOL_PATH" ]; then
  echo "Помилка: ZVOL не знайдено. Перевір Proxmox та ZFS."
  exit 1
fi

# Призначення диска до SCSI контролера
echo "Призначення диска до SCSI контролера..."
qm set ${VM_ID} --virtio0 ${VM_STORAGE}:vm-${VM_ID}-disk-0

# Підключення Cloud-Init диска
echo "Підключення Cloud-Init диска..."
qm set ${VM_ID} --ide2 ${VM_STORAGE}:cloudinit

# Встановлення типу операційної системи
echo "Встановлення типу операційної системи..."
qm set ${VM_ID} --ostype l26

# Встановлення пріоритету завантаження
echo "Встановлення пріоритету завантаження..."
qm set ${VM_ID} --boot c --bootdisk virtio0

# Конвертація віртуальної машини у шаблон
echo "Конвертація віртуальної машини у шаблон..."
qm template ${VM_ID}

# Видалення раніше завантаженого Cloud-Image
echo "Видалення раніше завантаженого Cloud-Image..."
rm ./${CLOUD_IMAGE}

echo "Готово! Шаблон створений та готовий до клонування."
