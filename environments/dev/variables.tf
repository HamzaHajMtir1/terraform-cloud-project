variable "aws_region" {
  description = "Région de déploiement."
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Préfixe de nommage."
  type        = string
  default     = "cloud5"
}

variable "environment" {
  description = "Nom de l'environnement."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment doit valoir dev, test ou prod."
  }
}

variable "owner" {
  description = "Responsable des ressources (tag Owner)."
  type        = string
}

variable "vpc_cidr" {
  description = "Bloc réseau principal."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR des subnets publics (un par AZ)."
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "app_subnet_cidrs" {
  description = "CIDR des subnets privés applicatifs (un par AZ)."
  type        = list(string)
  default     = ["10.20.11.0/24", "10.20.12.0/24"]
}

variable "db_subnet_cidrs" {
  description = "CIDR des subnets privés base de données (un par AZ)."
  type        = list(string)
  default     = ["10.20.21.0/24", "10.20.22.0/24"]
}

variable "single_nat_gateway" {
  description = "Une seule NAT Gateway pour réduire les coûts."
  type        = bool
  default     = true
}
