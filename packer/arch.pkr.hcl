# https://wiki.archlinux.org/title/Install_Arch_Linux_via_SSH
# https://wiki.archlinux.org/title/archiso

packer {
  required_version = ">= 1.9.4"
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = ">= 1.1"
    }
    qemu = {
      version = ">= 1"
      source  = "github.com/hashicorp/qemu"
    }
    docker = {
      version = ">= 1.0"
      source  = "github.com/hashicorp/docker"
    }
    vagrant = {
      version = ">= 1"
      source  = "github.com/hashicorp/vagrant"
    }
    sshkey = {
      version = ">= 1.0.1"
      source  = "github.com/ivoronin/sshkey"
    }
  }
}

locals {
  #ovf_export_path    = "${path.cwd}/artifacts/${local.vm_name}"
  common_data_source = "http"
  build_username     = "devops"
  data_source_content = {
    "/meta-data" = file("${abspath(path.root)}/data/meta-data")
    "/user-data" = templatefile("${abspath(path.root)}/data/user-data.pkrtpl.hcl", {
      build_username   = local.build_username
      build_public_key = data.sshkey.install.public_key
    })
  }
  data_source_command = local.common_data_source == "http" ? "ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"" : "ds=\"nocloud\""
  vm_name             = "${local.vm_guest_os_family}-${local.vm_guest_os_name}-${local.vm_guest_os_version}-${var.build_version}"
  vm_guest_os_family  = "linux"
  vm_guest_os_name    = "arch"
  vm_guest_os_version = "2023.12.01"
}

source "docker" "arch" {
  image       = "arch-base:1"
  commit      = true
  run_command = ["-d", "-i", "-t", "{{.Image}}", "/bin/bash"]
}

data "sshkey" "install" {
  type = "rsa"
}

source "qemu" "arch" {
  iso_url          = "https://mirror.5i.fi/archlinux/iso/${local.vm_guest_os_version}/archlinux-${local.vm_guest_os_version}-x86_64.iso"
  iso_checksum     = "sha256:50c688670abf27345b3effa03068b0302810f8da0db80d06d11a932c3ef99056"
  output_directory = "output-arch-qemu"
  shutdown_command = "sudo -S -E shutdown -P now"

  communicator         = "ssh"
  ssh_username         = local.build_username
  ssh_private_key_file = data.sshkey.install.private_key_path
  ssh_timeout          = "5m"

  cpus        = 2
  memory      = 2048
  disk_size   = "40960M"
  format      = "qcow2"
  accelerator = "kvm"

  http_content = local.common_data_source == "http" ? local.data_source_content : null
  boot_command = [
    "c<wait>",
    "linux /arch/boot/x86_64/vmlinuz-linux archisobasedir=arch archisodevice=UUID=$${ARCHISO_UUID}",
    " ${local.data_source_command}",
    "<enter><wait>",
    "initrd /arch/boot/x86_64/initramfs-linux.img",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]
  boot_wait         = "10s"
  boot_key_interval = "25ms"

  vm_name        = local.vm_name
  net_device     = "virtio-net"
  disk_interface = "virtio"

  efi_boot          = true
  efi_firmware_code = "/usr/share/OVMF/x64/OVMF_CODE.fd"
  efi_firmware_vars = "/usr/share/OVMF/x64/OVMF_VARS.fd"
}

build {
  sources = [
    "source.docker.arch",
    "source.qemu.arch",
  ]

  provisioner "ansible" {
    user          = local.build_username
    playbook_file = "${path.cwd}/../ansible/create.yml"
    #role_paths           = "${path.cwd}/ansible/roles"
    #galaxy_file          = "${path.cwd}/ansible/requirements.yml"
    #galaxy_force_install = true
    ansible_env_vars = [
      "ANSIBLE_CONFIG=${path.cwd}/ansible.cfg"
    ]
    extra_arguments = [
      "--extra-vars", "display_skipped_hosts=false",
    ]
  }

  post-processor "docker-tag" {
    repository = "arch-test-image"
    tags       = [var.build_version]
    only       = ["docker.arch"]
  }

  post-processor "vagrant" {
    only                = ["qemu.arch"]
    keep_input_artifact = true
    provider_override   = "libvirt"
  }
}
