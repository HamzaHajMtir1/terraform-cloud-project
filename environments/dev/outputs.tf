output "vpc_id" {
  description = "ID du VPC dev."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Subnets publics."
  value       = module.network.public_subnet_ids
}

output "app_subnet_ids" {
  description = "Subnets privés applicatifs."
  value       = module.network.app_subnet_ids
}

output "db_subnet_ids" {
  description = "Subnets privés base de données."
  value       = module.network.db_subnet_ids
}
