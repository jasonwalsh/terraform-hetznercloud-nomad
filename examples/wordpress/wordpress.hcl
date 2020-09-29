job "wordpress" {
  datacenters = ["dc1"]

  group "wordpress" {
    count = 1

    task "wordpress" {
      config {
        image        = "wordpress"
        network_mode = "host"
      }

      driver = "docker"

      resources {
        network {
          port "http" {
            static = 80
          }
        }
      }

      service {
        name = "wordpress"
        port = "http"
      }
    }
  }
}
