# Provider
terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc03"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = var.proxmox_tls_insecure
}

# VM General
resource "proxmox_vm_qemu" "vm_cloud_init" {
  name        = var.vm_name
  target_node = var.target_node
  clone       = var.clone_template
  onboot      = var.vm_onboot

  # CPU & Memory
  cpu {
    cores   = var.vm_cores
    sockets = var.vm_sockets
    type    = var.vm_cpu_type
  }

  memory  = var.vm_memory
  balloon = var.vm_balloon

  # Boot Order
  boot = var.vm_boot_order

  # Disks
  disk {
    slot    = var.disk_slot
    type    = var.disk_type
    storage = var.disk_storage
    size    = var.disk_size
  }

  disk {
    slot    = var.cloudinit_slot
    type    = var.cloudinit_type
    storage = var.disk_storage
  }

  # Serial Port
  serial {
    id   = var.serial_port_id
    type = var.serial_port_type
  }

  # Networks
  network {
    id     = var.network_id
    model  = var.network_model
    bridge = var.network_bridge
  }

  # Cloud-Init
  os_type     = var.vm_os_type
  ciuser      = var.vm_user
  cipassword  = var.vm_password
  ciupgrade   = var.vm_upgrade
  sshkeys     = var.ssh_public_key
  ipconfig0   = "ip=${var.vm_ip}/24,gw=${var.vm_gateway}"
  agent       = var.agent_activation
}
