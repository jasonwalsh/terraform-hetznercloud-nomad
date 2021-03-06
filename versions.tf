terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    http = {
      source = "hashicorp/http"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
  required_version = ">= 0.13"
}
