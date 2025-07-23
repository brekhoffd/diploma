#!/bin/bash

echo Створюємо шаблон віртуальної машини...

# Cloud Image
CLOUD_IMAGE=noble-server-cloudimg-amd64.img

# Налаштовуємо віртуальну машину
VM_ID=1000
VM_NAME=ubuntu
VM_MEM=4096
VM_CORES=2
VM_STORAGE=raid-zfs
VM_DISK_SIZE=32G

# Завантажуємо Cloud Image
wget https://cloud-images.ubuntu.com/noble/current/${CLOUD_IMAGE}

# Створюємо віртуальну машину
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
qm importdisk ${VM_ID} ${CLOUD_IMAGE} ${VM_STORAGE}

# Призначаємо диск до SCSI контролера
qm set ${VM_ID} --scsi0 ${VM_STORAGE}:vm-${VM_ID}-disk-0

# Підключаємо cloud-init диск
qm set ${VM_ID} --ide2 ${VM_STORAGE}:cloudinit

# Встановлюємо пріоритет завантаження
qm set ${VM_ID} --boot c --bootdisk scsi0

# (Опціонально) Редагуємо розмір диску
qm resize ${VM_ID} scsi0 ${VM_DISK_SIZE}

# Конвертуємо ВМ у шаблон
qm template ${VM_ID}

# Видаляємо раніше завантажений Cloud Image
rm ./${CLOUD_IMAGE}

echo Шаблон створений та готовий до клонування!
