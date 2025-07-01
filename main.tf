terraform {
    required_providers {
        proxmox = {
            source = "telmate/proxmox"
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

    disk {
        size            = "32G"
        type            = "scsi"
        storage         = "local-lvm"
        discard         = "on"
    }

    network {
        model     = "virtio"
        bridge    = "vmbr0"
        firewall  = false
        link_down = false
    }

}
