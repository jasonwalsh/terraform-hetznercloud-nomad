## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| hcloud | n/a |
| http | n/a |
| tls | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create\_key\_pair | Creates a 2048-bit RSA key pair | `bool` | `false` | no |
| nomad\_version | The nomad version | `string` | `""` | no |
| private\_key | The private key file location | `string` | `"~/.ssh/id_rsa"` | no |
| public\_key | The public key file location | `string` | `"~/.ssh/id_rsa.pub"` | no |

## Outputs

| Name | Description |
|------|-------------|
| load\_balancer | IPv4 Address of the Load Balancer |
