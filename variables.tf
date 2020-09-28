variable "create_key_pair" {
  default     = false
  description = ""
  type        = bool
}

variable "load_balancer_type" {
  default     = "lb11"
  description = ""
  type        = string
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

variable "server_count" {
  default     = 3
  description = ""
  type        = number
}

variable "server_type" {
  default     = "cx11"
  description = ""
  type        = string
}
