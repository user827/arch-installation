variable "build_version" {
  type        = string
  description = "Build version"
  default     = "noversion"
}

variable "root_disk_password" {
  type      = string
  sensitive = true
  default   = "hello"
}

# For secure boot see https://discuss.hashicorp.com/t/building-uefi-images-with-qemu-kvm/18061
variable "efi_firmware_code" {
  type    = string
  default = "/usr/share/OVMF/x64/OVMF_CODE.fd"
}

variable "efi_firmware_vars" {
  type    = string
  default = "/usr/share/OVMF/x64/OVMF_VARS.fd"
}
