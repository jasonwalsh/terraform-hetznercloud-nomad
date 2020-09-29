output "load_balancer" {
  value = module.server.load_balancer
}

output "nomad_version" {
  value = local.nomad_version
}
