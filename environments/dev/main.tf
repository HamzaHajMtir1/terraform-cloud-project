# -----------------------------------------------------------------------------
# Composition de l'environnement : mêmes modules pour dev, test et prod.
# Seules les valeurs (<env>.auto.tfvars) et la clé du backend changent.
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }

  # 10.x.1.0/24, 10.x.2.0/24 (public) ; 10.x.11-12 (app) ; 10.x.21-22 (db)
  public_subnet_cidrs = [for i in [1, 2] : cidrsubnet(var.vpc_cidr, 8, i)]
  app_subnet_cidrs    = [for i in [11, 12] : cidrsubnet(var.vpc_cidr, 8, i)]
  db_subnet_cidrs     = [for i in [21, 22] : cidrsubnet(var.vpc_cidr, 8, i)]
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "network" {
  source = "../../modules/network"

  name_prefix         = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  azs                 = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnet_cidrs = local.public_subnet_cidrs
  app_subnet_cidrs    = local.app_subnet_cidrs
  db_subnet_cidrs     = local.db_subnet_cidrs
  enable_nat_gateway  = var.enable_nat_gateway
  single_nat_gateway  = var.single_nat_gateway
  enable_s3_endpoint  = true
}

module "security" {
  source = "../../modules/security"

  name_prefix = local.name_prefix
  vpc_id      = module.network.vpc_id
}

module "load_balancer" {
  source = "../../modules/load-balancer"

  name_prefix       = local.name_prefix
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
}

module "compute" {
  source = "../../modules/compute"

  name_prefix           = local.name_prefix
  project_name          = var.project_name
  environment           = var.environment
  app_subnet_ids        = module.network.app_subnet_ids
  app_sg_id             = module.security.app_sg_id
  target_group_arn      = module.load_balancer.target_group_arn
  instance_profile_name = module.security.instance_profile_name
  instance_type         = var.instance_type
  min_size              = var.min_size
  max_size              = var.max_size
  desired_capacity      = var.desired_capacity
  tags                  = local.common_tags
}

module "database" {
  source = "../../modules/database"

  name_prefix             = local.name_prefix
  db_subnet_ids           = module.network.db_subnet_ids
  db_sg_id                = module.security.db_sg_id
  instance_class          = var.db_instance_class
  backup_retention_period = var.db_backup_retention
  deletion_protection     = var.db_deletion_protection
}

module "storage" {
  source = "../../modules/storage"
  count  = var.enable_storage ? 1 : 0

  name_prefix         = local.name_prefix
  log_expiration_days = var.log_expiration_days
}
