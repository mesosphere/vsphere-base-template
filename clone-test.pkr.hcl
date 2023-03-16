packer {
  required_plugins {
    sshkey = {
      version = ">= 1.0.1"
      source  = "github.com/ivoronin/sshkey"
    }
    vsphere = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

variable "template_manifest" {
  type    = string
  default = ""
}

variable "ssh_username" {
  type    = string
  default = ""
}

variable "template" {
    type = string
    default = ""
}

variable "ssh_public_key" {
    type = string
    default = ""
}

variable "ssh_agent_auth" {
  type = bool
  default = false
}



// conntextion details
variable "vcenter_server" {
  type    = string
  default = "${env("VSPHERE_SERVER")}"
}

variable "vsphere_user" {
  type    = string
  default = "${env("VSPHERE_USERNAME")}"
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

variable "manifest_output" {
  type    = string
  default = ""
}

data "sshkey" "install" {
  name = "base-image-test"
}



locals {
  manifestfile = var.template_manifest != "" ? file(var.template_manifest) : ""
  builds = local.manifestfile != "" ? lookup(jsondecode(local.manifestfile), "builds", []) : []
  build = length(local.builds) > 0 ? local.builds[0] : convert("{}", object)
  custom_data = contains(keys(local.build), "custom_data") ? local.build["custom_data"] : {}
  template = lookup(local.custom_data, "template_name", var.template)
  ssh_username = lookup(local.custom_data, "ssh_username", var.ssh_username)
  base_cloudinit = <<EOF
#cloud-config
users:
  - name: ${local.ssh_username}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo, wheel
    lock_passwd: true
    ssh_authorized_keys:
      - ${var.ssh_public_key == "" ? data.sshkey.install.public_key : var.ssh_public_key}
EOF
  cloudinit_metadata = <<EOF
instance-id: ${var.vm_name}
local-hostname: ${var.vm_name}
network:
  version: 2
  ethernets:
    nics:
      match:
        name: ens*
      dhcp4: yes
    nics:
      match:
        name: eth*
      dhcp4: yes
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
  ssh_timeout                  = "60m"
  ssh_username                 = local.ssh_username
  ssh_agent_auth               = var.ssh_agent_auth
  template                     = local.template
  username                     = var.vsphere_user
  vcenter_server               = var.vcenter_server
  vm_name                      = var.vm_name
  resource_pool                = var.vsphere_resource_pool
  // # once the test is done we don't need the vm
  // destroy = true
  disk_size             = 40960

  // cd_label = "cidata"
  // cd_content = {
  //   "/user-data"       = local.base_cloudinit,
  //   "/user-data.txt"       = local.base_cloudinit,
  //   "/meta-data"       = "",
  // }

  configuration_parameters = {
    "guestinfo.userdata" = base64encode(local.base_cloudinit),
    "guestinfo.userdata.encoding" = "base64",
    "guestinfo.metadata" = base64encode(local.cloudinit_metadata)
    "guestinfo.metadata.encoding" = "base64"
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

  post-processor "manifest" {
    output     = var.manifest_output == "" ? "manifests/test/${var.vm_name}.json" : var.manifest_output
    strip_path = true
    custom_data = {
      template      = local.template
      template_manifest = var.template_manifest
      template_name = join("/", [var.vsphere_folder, var.vm_name])
      ssh_username  = local.ssh_username
      datacenter    = var.vsphere_datacenter
    }
  }
}
