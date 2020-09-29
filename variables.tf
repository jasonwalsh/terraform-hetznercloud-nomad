variable "create_key_pair" {
  default     = false
  description = ""
  type        = bool
}

variable "nomad_version" {
  default     = ""
  description = ""
  type        = string
}

variable "private_key" {
  default     = "~/.ssh/id_rsa"
  description = ""
  type        = string
}

variable "public_key" {
  default     = "~/.ssh/id_rsa.pub"
  description = ""
  type        = string
}
