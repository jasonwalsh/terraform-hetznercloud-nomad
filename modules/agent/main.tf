locals {
  configuration = (
    var.server ?
    jsonencode(
      merge(
        {
          server = {
            bootstrap_expect = var.server_count
            enabled          = true

            server_join = {
              retry_interval = "15s"
              retry_join     = [for server in hcloud_server.nomad : server.ipv4_address]
            }
          }
        },
        var.configuration
      )
    ) :
    jsonencode(
      merge(
        {
          client = {
            enabled = true
            servers = var.servers
          }
        },
        var.configuration
      )
    )
  )

  mode = var.server ? "server" : "client"
}

resource "hcloud_network_subnet" "nomad" {
  ip_range     = var.ip_range
  network_id   = var.network_id
  network_zone = "eu-central"
  type         = "cloud"
}

resource "hcloud_server" "nomad" {
  count = var.server_count

  image       = "ubuntu-20.04"
  name        = format("nomad-%s-%d", local.mode, count.index + 1)
  server_type = var.server_type
  ssh_keys    = [var.ssh_key]

  user_data = <<EOF
#cloud-config
${yamlencode(var.user_data)}
  EOF

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]

    connection {
      host        = self.ipv4_address
      private_key = var.private_key
      type        = "ssh"
      user        = "root"
    }
  }
}

resource "hcloud_server_network" "nomad" {
  count = var.server_count

  ip         = cidrhost(var.ip_range, count.index + 4)
  network_id = var.network_id
  server_id  = hcloud_server.nomad[count.index].id
}

resource "null_resource" "nomad" {
  count = var.server_count

  triggers = {
    configuration = local.configuration
    instance_ids  = join(",", hcloud_server.nomad[*].id)
  }

  connection {
    host        = hcloud_server.nomad[count.index].ipv4_address
    private_key = var.private_key
    type        = "ssh"
    user        = "root"
  }

  provisioner "file" {
    content     = local.configuration
    destination = format("/etc/nomad.d/%s.json", local.mode)
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl start nomad"
    ]
  }
}

resource "hcloud_load_balancer" "nomad" {
  count = var.server ? 1 : 0

  load_balancer_type = var.load_balancer_type
  location           = "nbg1"
  name               = "nomad"
}

resource "hcloud_load_balancer_target" "nomad" {
  count = var.server ? var.server_count : 0

  load_balancer_id = join("", hcloud_load_balancer.nomad[*].id)
  server_id        = hcloud_server.nomad[count.index].id
  type             = "server"
}

resource "hcloud_load_balancer_service" "nomad" {
  count = var.server ? 1 : 0

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
  load_balancer_id = join("", hcloud_load_balancer.nomad[*].id)
  protocol         = "http"
}
