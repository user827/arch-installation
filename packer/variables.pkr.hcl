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

variable "efi_firmware_code" {
  type      = string
  default   = "/usr/share/OVMF/x64/OVMF_CODE.fd"
}

variable "efi_firmware_vars" {
  type      = string
  default   = "/usr/share/OVMF/x64/OVMF_VARS.fd"
}
