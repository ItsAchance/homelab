terraform {
    required_providers {
        proxmox = {
            source = "telmate/proxmox"
            version = "3.0.2-rc01"
        }
    }
}

variable "pm_url" {
  type        = string
}

variable "pm_token_secret" {
  type        = string
}

variable "pm_token_id" {
  type        = string
}

variable "ci_password" {
  type        = string
}

variable "ci_user" {
  type        = string
}

provider "proxmox" {
    pm_api_url          = var.pm_url
    pm_api_token_id     = var.pm_token_id
    pm_api_token_secret = var.pm_token_secret
    pm_tls_insecure     = true
}

resource "proxmox_vm_qemu" "vm-instance" {
    name                = "vm-instance"
    target_node         = "pve"
    clone               = "vm-template"
    full_clone          = true
    scsihw              = "virtio-scsi-single"
    cores               = 1
    memory              = 1024

  # Cloud-Init configuration
  ciupgrade             = true
  ipconfig0             = "ip=dhcp,ip6=dhcp"
  skip_ipv6             = true
  ciuser                = var.ci_user
  cipassword            = var.ci_password


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
