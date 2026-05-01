# Module: networking

Creates the network layer: Scaleway VPC, private network with a dedicated CIDR, and a managed public gateway (NAT) for controlled outbound internet access.

## Resources

| Resource | Description |
|---|---|
| `scaleway_vpc` | VPC container |
| `scaleway_vpc_private_network` | Private network with `/20` subnet |
| `scaleway_vpc_public_gateway_ip` | Reserved public IP for NAT |
| `scaleway_vpc_public_gateway` | Managed NAT gateway |
| `scaleway_vpc_public_gateway_dhcp` | DHCP config for the subnet |
| `scaleway_vpc_gateway_network` | Wires gateway ↔ private network |

## Usage

```hcl
module "networking" {
  source = "../../modules/networking"

  project_name        = "devops-factory"
  env                 = "dev"
  region              = "fr-par"
  private_subnet_cidr = "10.0.0.0/20"
  gateway_type        = "VPC-GW-S"
}
```

## Outputs

| Output | Description |
|---|---|
| `vpc_id` | VPC identifier |
| `private_network_id` | Pass to `kapsule-cluster` |
| `gateway_id` | Public gateway ID |
| `gateway_public_ip` | NAT egress IP — add to external allowlists |
