variable "configuration" {
  default     = {}
  description = ""
  type        = map(any)
}

variable "ip_range" {
  description = ""
  type        = string
}

variable "load_balancer_type" {
  default     = "lb11"
  description = ""
  type        = string
}

variable "network_id" {
  description = ""
  type        = string
}

variable "private_key" {
  description = ""
  type        = string
}

variable "server" {
  default     = true
  description = ""
  type        = bool
}

variable "servers" {
  default     = []
  description = ""
  type        = set(string)
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

variable "ssh_key" {
  description = ""
  type        = string
}

variable "user_data" {
  default     = {}
  description = ""
  type        = any
}
