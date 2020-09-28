provider "hcloud" {}

locals {
  configuration = {
    data_dir = "/var/lib/nomad"

    server = {
      bootstrap_expect = var.server_count
      enabled          = true

      server_join = {
        retry_interval = "15s"
        retry_join     = [for server in hcloud_server.nomad : server.ipv4_address]
      }
    }
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

resource "hcloud_network_subnet" "nomad" {
  ip_range     = "10.0.1.0/24"
  network_id   = hcloud_network.nomad.id
  network_zone = "eu-central"
  type         = "cloud"
}

resource "hcloud_server" "nomad" {
  count = var.server_count

  image       = "ubuntu-20.04"
  name        = format("nomad-server-%d", count.index + 1)
  server_type = var.server_type
  ssh_keys    = [hcloud_ssh_key.ssh_key.id]

  user_data = <<EOF
#cloud-config
${yamlencode(local.user_data)}
  EOF

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]

    connection {
      host        = self.ipv4_address
      private_key = local.private_key
      type        = "ssh"
      user        = "root"
    }
  }
}

resource "hcloud_server_network" "nomad" {
  count = var.server_count

  ip         = format("10.0.1.%d", count.index + 4)
  network_id = hcloud_network.nomad.id
  server_id  = hcloud_server.nomad[count.index].id
}

resource "null_resource" "nomad" {
  count = var.server_count

  triggers = {
    configuration = jsonencode(local.configuration)
    instance_ids  = join(",", hcloud_server.nomad[*].id)
  }

  connection {
    host        = hcloud_server.nomad[count.index].ipv4_address
    private_key = local.private_key
    type        = "ssh"
    user        = "root"
  }

  provisioner "file" {
    content     = jsonencode(local.configuration)
    destination = "/etc/nomad.d/server.json"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl start nomad"
    ]
  }
}

resource "hcloud_load_balancer" "nomad" {
  load_balancer_type = var.load_balancer_type
  location           = "nbg1"
  name               = "nomad"
}

resource "hcloud_load_balancer_target" "nomad" {
  count = var.server_count

  load_balancer_id = hcloud_load_balancer.nomad.id
  server_id        = hcloud_server.nomad[count.index].id
  type             = "server"
}

resource "hcloud_load_balancer_service" "nomad" {
  health_check {
    http {
      path = "/"

      status_codes = [
        "2??",
        "3??"
      ]
    }

    interval = 15
    port     = 4646
    protocol = "http"
    retries  = 3
    timeout  = 10
  }

  destination_port = 4646
  listen_port      = 80
  load_balancer_id = hcloud_load_balancer.nomad.id
  protocol         = "http"
}
