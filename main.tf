provider "hcloud" {}

locals {
  configuration = {
    data_dir = "/var/lib/nomad"
  }

  download_url = format(
    "https://releases.hashicorp.com/nomad/%s/nomad_%s_linux_amd64.zip",
    local.nomad_version,
    local.nomad_version
  )

  private_key = coalesce(
    join("", tls_private_key.private_key[*].private_key_pem),
    file(pathexpand(var.private_key))
  )

  public_key = coalesce(
    join("", tls_private_key.private_key[*].public_key_openssh),
    file(pathexpand(var.public_key))
  )

  nomad_version = coalesce(
    var.nomad_version,
    jsondecode(data.http.nomad.body)["current_version"]
  )
}

data "http" "nomad" {
  request_headers = {
    Accept = "application/json"
  }

  url = "https://checkpoint-api.hashicorp.com/v1/check/nomad"
}

resource "tls_private_key" "private_key" {
  count = var.create_key_pair ? 1 : 0

  algorithm = "RSA"
}

resource "hcloud_ssh_key" "ssh_key" {
  name       = "nomad"
  public_key = local.public_key
}

resource "hcloud_network" "nomad" {
  ip_range = "10.0.0.0/8"
  name     = "nomad"
}

module "server" {
  source = "./modules/agent"

  configuration = local.configuration
  ip_range      = "10.0.1.0/24"
  private_key   = local.private_key
  network_id    = hcloud_network.nomad.id
  ssh_key       = hcloud_ssh_key.ssh_key.id
  user_data     = local.user_data
}

module "client" {
  source = "./modules/agent"

  configuration = local.configuration
  ip_range      = "10.0.2.0/24"
  private_key   = local.private_key
  network_id    = hcloud_network.nomad.id
  server        = false
  servers       = module.server.ip_addresses
  server_count  = 1
  ssh_key       = hcloud_ssh_key.ssh_key.id
  user_data     = local.user_data
}
