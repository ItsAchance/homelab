terraform {
    required_providers {
        proxmox = {
            source = "telmate/proxmox"
            version = "3.0.2-rc01"
        }
    }
}

variable "token_secret" {
  type        = string
}

variable "token_id" {
  type        = string
}

provider "proxmox" {
    pm_api_url          = "https://pve.achance.se:8006/api2/json"
    pm_api_token_id     = var.token_id
    pm_api_token_secret = var.token_secret
    pm_tls_insecure     = true
}

resource "proxmox_vm_qemu" "vm-instance" {
    name                = "vm-instance"
    target_node         = "pve"
    clone               = "vm-template"
    full_clone          = true
    cores               = 1
    memory              = 1024
    agent               = 1

  # Cloud-Init Drive (slot ide0)
    disk {
        slot            = "ide0"
        type            = "cloudinit"
        storage         = "local-lvm"
    }

 # HDD (slot virtio0)
    disk {
        slot            = "scsi0"
        size            = "32G"
        type            = "disk"
        storage         = "local-lvm"
        discard         = true
    }

    network {
        id              = 0
        model           = "virtio"
        bridge          = "vmbr0"
        firewall        = false
        link_down       = false
    }

    serial {
        id              = 0
        type            = "socket"
  }


}
