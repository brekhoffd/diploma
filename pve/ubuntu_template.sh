#!/bin/bash

echo "Створюємо шаблон віртуальної машини..."

# Cloud Image
CLOUD_IMAGE=noble-server-cloudimg-amd64.img

# Налаштовуємо віртуальну машину
VM_ID=1000
VM_NAME=ubuntu
VM_MEM=1024
VM_CORES=1
VM_STORAGE=raid-zfs

# Завантажуємо Cloud-Image
echo "Завантажуємо Cloud-Image..."
wget https://cloud-images.ubuntu.com/noble/current/${CLOUD_IMAGE}

# Створюємо віртуальну машину
echo "Створюємо віртуальну машину..."
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

# Імпортуємо диск
echo "Імпортуємо диск..."
qm importdisk ${VM_ID} ${CLOUD_IMAGE} ${VM_STORAGE}

# Очікуємо створення ZVOL-пристрою після імпорту диска
echo "Очікуємо створення ZVOL-пристрою після імпорту диска..."
sleep 5

# Перевіряємо наявність ZVOL-пристрою
echo "Перевіряємо наявність ZVOL-пристрою..."
ZVOL_PATH="/dev/zvol/${VM_STORAGE}/vm-${VM_ID}-disk-0"
echo "Перевіряємо наявність ZVOL-пристрою: ${ZVOL_PATH}..."
for i in {1..20}; do
  if [ -e "$ZVOL_PATH" ]; then
    echo "ZVOL знайдено!"
    break
  fi
  sleep 1
done

if [ ! -e "$ZVOL_PATH" ]; then
  echo "Помилка: ZVOL не знайдено. Перевір Proxmox та ZFS."
  exit 1
fi

# Призначаємо диск до SCSI контролера
echo "Призначаємо диск до SCSI контролера..."
qm set ${VM_ID} --virtio0 ${VM_STORAGE}:vm-${VM_ID}-disk-0

# Підключаємо cloud-init диск
echo "Підключаємо cloud-init диск..."
qm set ${VM_ID} --ide2 ${VM_STORAGE}:cloudinit

# Встановлюємо тип операційної системи
echo "Встановлюємо тип операційної системи..."
qm set ${VM_ID} --ostype l26

# Встановлюємо пріоритет завантаження
echo "Встановлюємо пріоритет завантаження..."
qm set ${VM_ID} --boot c --bootdisk virtio0

# Конвертуємо ВМ у шаблон
echo "Конвертуємо ВМ у шаблон..."
qm template ${VM_ID}

# Видаляємо раніше завантажений Cloud-Image
echo "Видаляємо раніше завантажений Cloud-Image..."
rm ./${CLOUD_IMAGE}

echo "Шаблон створений та готовий до клонування!"
