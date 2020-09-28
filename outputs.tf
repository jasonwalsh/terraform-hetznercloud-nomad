output "ipv4_address" {
  value = [for server in hcloud_server.nomad : server.ipv4_address]
}

output "nomad_version" {
  value = local.nomad_version
}
