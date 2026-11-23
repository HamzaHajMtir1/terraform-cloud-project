output "vpc_id" {
  description = "ID du VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR du VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs des subnets publics (pour l'ALB)."
  value       = [for az in var.azs : aws_subnet.public[az].id]
}

output "app_subnet_ids" {
  description = "IDs des subnets privés applicatifs (pour l'Auto Scaling Group)."
  value       = [for az in var.azs : aws_subnet.app[az].id]
}

output "db_subnet_ids" {
  description = "IDs des subnets privés base de données (pour le DB subnet group RDS)."
  value       = [for az in var.azs : aws_subnet.db[az].id]
}

output "nat_gateway_ids" {
  description = "IDs des NAT Gateways créées."
  value       = [for az in local.nat_azs : aws_nat_gateway.this[az].id]
}
