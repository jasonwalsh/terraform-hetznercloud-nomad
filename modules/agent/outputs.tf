output "load_balancer" {
  value = join("", hcloud_load_balancer.nomad[*].ipv4)
}

output "ip_addresses" {
  value = hcloud_server.nomad[*].ipv4_address
}
