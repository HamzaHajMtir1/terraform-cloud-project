variable "name_prefix" {
  description = "Préfixe des noms : <projet>-<environnement> (ALB et Target Group : 32 caractères max)."
  type        = string

  validation {
    condition     = length(var.name_prefix) <= 25
    error_message = "name_prefix trop long : les noms d'ALB et de Target Group sont limités à 32 caractères."
  }
}

variable "vpc_id" {
  description = "ID du VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "Subnets publics de l'ALB (au moins 2 AZ)."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "Un ALB nécessite au moins deux subnets dans deux AZ différentes."
  }
}

variable "alb_sg_id" {
  description = "Security Group de l'ALB."
  type        = string
}

variable "target_port" {
  description = "Port des instances cibles."
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Chemin HTTP testé par le health check."
  type        = string
  default     = "/"
}
