output "alb_url" {
  description = "URL publique de l'application."
  value       = module.load_balancer.alb_url
}

output "asg_name" {
  description = "Auto Scaling Group."
  value       = module.compute.asg_name
}

output "db_endpoint" {
  description = "Endpoint RDS (privé)."
  value       = module.database.db_endpoint
}

output "db_password" {
  description = "Mot de passe RDS (sensible)."
  value       = module.database.db_password
  sensitive   = true
}

output "data_bucket" {
  description = "Bucket S3 de données."
  value       = one(module.storage[*].bucket_name)
}

output "vpc_id" {
  description = "ID du VPC."
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
