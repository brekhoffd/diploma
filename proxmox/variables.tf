# --- Provider Authentication ---
variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://192.168.88.1:8006/api2/json"
}

variable "proxmox_api_token_id" {
  description = "Proxmox API Token ID"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API Token Secret"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Disable TLS Verification"
  type        = bool
  default     = true
}

# --- VM General ---
variable "vm_name" {
  description = "Name Of The Virtual Machine"
  type        = string
  default     = "VM-TEST"
}

variable "target_node" {
  description = "Proxmox Node To Deploy"
  type        = string
  default     = "pve"
}

variable "clone_template" {
  description = "Name Template To Clone"
  type        = string
  default     = "ubuntu"
}

variable "vm_onboot" {
  description = "Start VM On Boot"
  type        = bool
  default     = true
}

# --- CPU & Memory ---
variable "vm_cores" {
  description = "Number Of CPU Cores"
  type        = number
  default     = 2
}

variable "vm_sockets" {
  description = "Number Of CPU Sockets"
  type        = number
  default     = 1
}

variable "vm_cpu_type" {
  description = "Type Of CPU"
  type        = string
  default     = "host"
}

variable "vm_memory" {
  description = "RAM Memory In MB"
  type        = number
  default     = 4096
}

variable "vm_balloon" {
  description = "Ballooning Memory"
  type        = number
  default     = 0
}

# --- Boot ---
variable "vm_boot_order" {
  description = "Boot Device Order"
  type        = string
  default     = "order=virtio0"
}

# --- Disks ---
variable "disk_slot" {
  description = "Disk Slot"
  type        = string
  default     = "virtio0"
}

variable "disk_type" {
  description = "Disk Type"
  type        = string
  default     = "disk"
}

variable "disk_storage" {
  description = "Storage Pool"
  type        = string
  default     = "raid-zfs"
}

variable "disk_size" {
  description = "Disk Size"
  type        = string
  default     = "32G"
}

variable "cloudinit_slot" {
  description = "Slot For Cloud-Init Disk"
  type        = string
  default     = "ide2"
}

variable "cloudinit_type" {
  description = "Type For Cloud-Init Disk"
  type        = string
  default     = "cloudinit"
}

# --- Serial Port ---
variable "serial_port_id" {
  description = "Serial Port ID"
  type        = number
  default     = 0
}

variable "serial_port_type" {
  description = "Serial Port Type"
  type        = string
  default     = "socket"
}

# --- Network ---
variable "network_id" {
  description = "Network Interface ID"
  type        = number
  default     = 0
}

variable "network_model" {
  description = "Network Device Model"
  type        = string
  default     = "virtio"
}

variable "network_bridge" {
  description = "Network Bridge Name"
  type        = string
  default     = "vmbr0"
}

# --- Cloud-Init ---
variable "vm_os_type" {
  description = "Default OS Type"
  type        = string
  default     = "cloud-init"
}

variable "vm_user" {
  description = "Default User For Cloud-Init"
  type        = string
  sensitive   = true
}

variable "vm_password" {
  description = "User Password For Cloud-Init"
  type        = string
  sensitive   = true
}

variable "vm_upgrade" {
  description = "VM Upgrade After Cloning"
  type        = bool
  default     = true
}

variable "ssh_public_key" {
  description = "SSH Public Key"
  type        = string
  sensitive   = true
}

variable "vm_ip" {
  description = "VM Static IP Address"
  type        = string
  default     = "192.168.88.199"
}

variable "vm_gateway" {
  description = "VM Default Gateway"
  type        = string
  default     = "192.168.88.254"
}

variable "agent_act" {
  description = "Qemu Guest Agent Activation"
  type        = number
  default     = 1
}
