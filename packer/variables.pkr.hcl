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
