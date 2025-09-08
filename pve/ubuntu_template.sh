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

# Версія Cloud-Image для шаблону
CLOUD_IMAGE="noble-server-cloudimg-amd64.img"

# Налаштування шаблону віртуальної машини
VM_ID="1000"
VM_NAME="ubuntu"
VM_MEM="1024"
VM_CORES="1"
VM_STORAGE="raid-zfs"

# Початкове повідомлення
echo
echo "Створення шаблону віртуальної машини!"

# Завантаження Cloud-Image
echo
echo "Завантаження Cloud-Image..."
wget https://cloud-images.ubuntu.com/noble/current/${CLOUD_IMAGE}

# Створення віртуальної машини
echo
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
echo
echo "Імпорт диска..."
qm importdisk ${VM_ID} ${CLOUD_IMAGE} ${VM_STORAGE}

# Очікування створення ZVOL після імпорту диска
echo
echo "Створення ZVOL після імпорту диска..."
sleep 10

# Перевірка наявності ZVOL
ZVOL_PATH="/dev/zvol/${VM_STORAGE}/vm-${VM_ID}-disk-0"
echo
echo "Перевірка наявності ZVOL: ${ZVOL_PATH}..."
for i in {1..10}; do
  if [ -e "$ZVOL_PATH" ]; then
    echo "ZVOL знайдено."
    break
  fi
  sleep 1
done

if [ ! -e "$ZVOL_PATH" ]; then
  echo
  echo "Помилка: ZVOL не знайдено. Перевір Proxmox та ZFS."
  exit 1
fi

# Призначення диска до SCSI контролера
echo
echo "Призначення диска до SCSI контролера..."
qm set ${VM_ID} --virtio0 ${VM_STORAGE}:vm-${VM_ID}-disk-0

# Підключення Cloud-Init диска
echo
echo "Підключення Cloud-Init диска..."
qm set ${VM_ID} --ide2 ${VM_STORAGE}:cloudinit

# Встановлення типу операційної системи
echo
echo "Встановлення типу операційної системи..."
qm set ${VM_ID} --ostype l26

# Встановлення пріоритету завантаження
echo
echo "Встановлення пріоритету завантаження..."
qm set ${VM_ID} --boot c --bootdisk virtio0

# Конвертація віртуальної машини у шаблон
echo
echo "Конвертація віртуальної машини у шаблон..."
qm template ${VM_ID}

# Видалення раніше завантаженого Cloud-Image
echo
echo "Видалення раніше завантаженого Cloud-Image..."
rm ./${CLOUD_IMAGE}

# Вивід кінцевого повідомлення
echo
echo "Створення шаблону віртуальної машини завершено!"
echo
