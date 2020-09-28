locals {
  user_data = {
    package_update = true

    packages = [
      "docker.io",
      "unzip"
    ]

    runcmd = [
      format("wget -O nomad.zip %s", local.download_url),
      "unzip nomad.zip -d /usr/local/bin",
      "rm nomad.zip",
      "mkdir /etc/nomad.d"
    ]

    write_files = [
      {
        content     = base64encode(file("${path.module}/files/nomad.service"))
        encoding    = "b64"
        owner       = "root:root"
        path        = "/etc/systemd/system/nomad.service"
        permissions = "0644"
      }
    ]
  }
}
