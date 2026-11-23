variable "name_prefix" {
  description = "Préfixe des noms : <projet>-<environnement> (ex : cloud5-dev)."
  type        = string
}

variable "vpc_cidr" {
  description = "Bloc CIDR principal du VPC."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr doit être un bloc CIDR IPv4 valide (ex : 10.20.0.0/16)."
  }
}

variable "azs" {
  description = "Zones de disponibilité utilisées (au moins 2)."
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "Il faut au moins deux zones de disponibilité pour la haute disponibilité."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR des subnets publics (ALB, NAT), un par AZ, dans le même ordre que azs."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.azs)
    error_message = "public_subnet_cidrs doit contenir un CIDR par zone de disponibilité."
  }
}

variable "app_subnet_cidrs" {
  description = "CIDR des subnets privés applicatifs (EC2), un par AZ."
  type        = list(string)

  validation {
    condition     = length(var.app_subnet_cidrs) == length(var.azs)
    error_message = "app_subnet_cidrs doit contenir un CIDR par zone de disponibilité."
  }
}

variable "db_subnet_cidrs" {
  description = "CIDR des subnets privés base de données (RDS), un par AZ."
  type        = list(string)

  validation {
    condition     = length(var.db_subnet_cidrs) == length(var.azs)
    error_message = "db_subnet_cidrs doit contenir un CIDR par zone de disponibilité."
  }
}

variable "enable_nat_gateway" {
  description = "Crée une NAT Gateway pour la sortie Internet des subnets applicatifs (PAYANT)."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "true = une seule NAT (économique, dev/test) ; false = une NAT par AZ (haute dispo, prod)."
  type        = bool
  default     = true
}
