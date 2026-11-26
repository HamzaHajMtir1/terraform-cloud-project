# --- Général -----------------------------------------------------------------

variable "aws_region" {
  description = "Région de déploiement (Learner Lab : us-east-1)."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Préfixe de nommage."
  type        = string
  default     = "cloud5"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,12}$", var.project_name))
    error_message = "project_name : 3 à 12 caractères, minuscules, chiffres et tirets."
  }
}

variable "environment" {
  description = "Nom de l'environnement."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment doit valoir dev, test ou prod."
  }
}

variable "owner" {
  description = "Responsable des ressources (tag Owner)."
  type        = string
}

# --- Réseau ------------------------------------------------------------------

variable "vpc_cidr" {
  description = "Bloc réseau principal (/16). Les subnets /24 en sont dérivés."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && endswith(var.vpc_cidr, "/16")
    error_message = "vpc_cidr doit être un bloc /16 valide (ex : 10.20.0.0/16)."
  }
}

variable "enable_nat_gateway" {
  description = "NAT Gateway (payante). Non nécessaire grâce à l'endpoint S3."
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Une seule NAT Gateway (true) ou une par AZ (false)."
  type        = bool
  default     = true
}

# --- Compute -----------------------------------------------------------------

variable "instance_type" {
  description = "Type d'instance EC2."
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Nombre minimal d'instances."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Nombre maximal d'instances."
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Capacité souhaitée (null = min_size). Sert au test d'Auto Scaling."
  type        = number
  default     = null
}

# --- Base de données ---------------------------------------------------------

variable "db_instance_class" {
  description = "Classe RDS."
  type        = string
  default     = "db.t3.micro"
}

variable "db_backup_retention" {
  description = "Rétention des sauvegardes RDS (jours)."
  type        = number
  default     = 0
}

variable "db_deletion_protection" {
  description = "Protection contre la suppression de la base."
  type        = bool
  default     = false
}

# --- Stockage ----------------------------------------------------------------

variable "enable_storage" {
  description = "Crée le bucket S3 de données (stack CloudFormation)."
  type        = bool
  default     = true
}

variable "log_expiration_days" {
  description = "Expiration des objets du bucket (jours)."
  type        = number
  default     = 30
}
