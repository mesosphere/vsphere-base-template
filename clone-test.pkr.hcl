packer {
  required_plugins {
    sshkey = {
      version = ">= 1.0.1"
      source  = "github.com/ivoronin/sshkey"
    }
    vsphere = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

variable "template" {
    type = string
}

variable "ssh_username" {
  type    = string
}



// conntextion details
variable "vcenter_server" {
  type    = string
  default = "${env("VSPHERE_SERVER")}"
}

variable "vsphere_user" {
  type    = string
  default = "${env("VSPHERE_USER")}"
}

variable "vsphere_password" {
  type    = string
  default = "${env("VSPHERE_PASSWORD")}"
}

variable "vsphere_insecure_connection" {
  type    = string
  default = "false"
}


// vsphere related details
variable "vsphere_cluster" {
  type = string
}

variable "vsphere_datastore" {
  type = string
}

variable "vsphere_datacenter" {
  type = string
}

variable "vsphere_network" {
  type = string
}

variable "vsphere_resource_pool" {
  type    = string
  default = ""
}

variable "vsphere_folder" {
  type    = string
  default = ""
}

// customizations
variable "vm_name" {
  type        = string
  default     = "packer-clone-test"
}

data "sshkey" "install" {}

locals {
  base_cloudinit = <<EOF
---
users:
- name: ${var.ssh_username}
  sudo: ALL=(ALL) NOPASSWD:ALL
  groups: sudo, wheel
  lock_passwd: true
  ssh_authorized_keys:
  - ${data.sshkey.install.public_key}
EOF
}


source "vsphere-clone" "clone_test" {
  CPUs                         = 1
  RAM                          = 2048
  cluster                      = var.vsphere_cluster
  communicator                 = "ssh"
  cpu_cores                    = 1
  datacenter                   = var.vsphere_datacenter
  datastore                    = var.vsphere_datastore
  folder                       = var.vsphere_folder
  insecure_connection          = var.vsphere_insecure_connection
  network                      = var.vsphere_network
  password                     = var.vsphere_password
  ssh_private_key_file         = data.sshkey.install.private_key_path
  ssh_timeout                  = "10m"
  ssh_username                 = var.ssh_username
  template                     = var.template
  username                     = var.vsphere_user
  vcenter_server               = var.vcenter_server
  vm_name                      = var.vm_name
  resource_pool                = var.vsphere_resource_pool

  cd_content = {
    "/user-data"       = local.base_cloudinit,
    "/meta-data"       = "",
  }

  create_snapshot     = false
  convert_to_template = false
}

build {
  sources = ["source.vsphere-clone.clone_test"]
  
  provisioner "shell" {
    execute_command = "sudo su -m root -c 'sh -eux {{.Path}}'"
    scripts         = [
      "${path.root}/tests/test_login.sh",
      "${path.root}/tests/test_disk.sh"
    ]
  }
}
