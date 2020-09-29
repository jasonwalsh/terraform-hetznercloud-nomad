variable "create_key_pair" {
  default     = false
  description = "Creates a 2048-bit RSA key pair"
  type        = bool
}

variable "nomad_version" {
  default     = ""
  description = "The nomad version"
  type        = string
}

variable "private_key" {
  default     = "~/.ssh/id_rsa"
  description = "The private key file location"
  type        = string
}

variable "public_key" {
  default     = "~/.ssh/id_rsa.pub"
  description = "The public key file location"
  type        = string
}
