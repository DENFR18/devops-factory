output "vpc_id" {
  description = "ID of the VPC"
  value       = scaleway_vpc.main.id
}

output "private_network_id" {
  description = "ID of the private network — pass to kapsule-cluster module"
  value       = scaleway_vpc_private_network.main.id
}

output "gateway_id" {
  description = "ID of the public gateway (NAT)"
  value       = scaleway_vpc_public_gateway.main.id
}

output "gateway_public_ip" {
  description = "Public IP address of the NAT gateway — used for egress allowlisting"
  value       = scaleway_vpc_public_gateway_ip.main.address
}
