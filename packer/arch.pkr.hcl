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
  }
}

locals {
  ssh_public_key_path  = "${path.cwd}/ssh_key.pub"
  ssh_private_key_path = "${path.cwd}/ssh_key"
  #ovf_export_path    = "${path.cwd}/artifacts/${local.vm_name}"
  common_data_source = "http"
  data_source_content = {
    "/meta-data" = file("${abspath(path.root)}/data/meta-data")
    "/user-data" = templatefile("${abspath(path.root)}/data/user-data.pkrtpl.hcl", {
      build_public_key = file(local.ssh_public_key_path)
    })
  }
  data_source_command = local.common_data_source == "http" ? "ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"" : "ds=\"nocloud\""
  vm_name             = "${local.vm_guest_os_family}-${local.vm_guest_os_name}-${local.vm_guest_os_version}-${var.build_version}"
  vm_guest_os_family  = "linux"
  vm_guest_os_name    = "arch"
  vm_guest_os_version = "2023.12.01"
}

source "docker" "arch" {
  image  = "archlinux:latest"
  commit = true
  # We want bash and fakeroot wants ulimit increase
  run_command = ["--ulimit", "nofile=1024:524288", "-d", "-i", "-t", "{{.Image}}", "/bin/bash"]
}

source "qemu" "arch" {
  iso_url          = "https://mirror.5i.fi/archlinux/iso/${local.vm_guest_os_version}/archlinux-${local.vm_guest_os_version}-x86_64.iso"
  iso_checksum     = "sha256:50c688670abf27345b3effa03068b0302810f8da0db80d06d11a932c3ef99056"
  output_directory = "output-arch-qemu-${var.build_version}"
  shutdown_command = "sudo -S -E shutdown -P now"

  communicator             = "ssh"
  ssh_username             = "root"
  ssh_private_key_file     = local.ssh_private_key_path
  ssh_timeout              = "5m"
  ssh_file_transfer_method = "sftp" # for ansible
  ssh_read_write_timeout   = "120s"

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
  boot_wait              = "15s"
  boot_key_interval      = "25ms"
  boot_keygroup_interval = "3s"

  vm_name        = local.vm_name
  net_device     = "virtio-net"
  disk_interface = "virtio"

  efi_boot          = true
  efi_firmware_code = var.efi_firmware_code
  efi_firmware_vars = var.efi_firmware_vars
}

build {
  sources = [
    "source.docker.arch",
    "source.qemu.arch",
  ]

  provisioner "file" {
    source      = "../scripts"
    destination = "/root"
  }

  provisioner "shell" {
    only   = ["qemu.arch"]
    script = "create_chroot.sh"
    environment_vars = [
      "CRYPT_PASSWORD=${var.root_disk_password}",
    ]
    #expect_disconnect = true # Gets stuck anyway with 'SSH client not available'
    #pause_after = "90s" # Don't try to continue until reboot has signaled connection error
  }

  provisioner "shell" {
    only   = ["docker.arch"]
    script = "docker_setup.sh"
  }

  post-processor "docker-tag" {
    repository = "arch-test-image"
    tags       = [var.build_version]
    only       = ["docker.arch"]
  }
}
