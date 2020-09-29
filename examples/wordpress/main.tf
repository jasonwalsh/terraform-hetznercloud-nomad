data "terraform_remote_state" "nomad" {
  backend = "local"

  config = {
    path = "../../terraform.tfstate"
  }
}

locals {
  outputs = data.terraform_remote_state.nomad.outputs
}

provider "nomad" {
  address = format("http://%s", local.outputs.load_balancer)
}

data "nomad_job_parser" "wordpress" {
  canonicalize = true
  hcl          = file("${path.module}/wordpress.hcl")
}

resource "nomad_job" "wordpress" {
  jobspec = data.nomad_job_parser.wordpress.hcl
}
