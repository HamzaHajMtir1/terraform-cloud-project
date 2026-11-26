variable "name_prefix" {
  description = "Préfixe des noms : <projet>-<environnement>."
  type        = string
}

variable "project_name" {
  description = "Nom du projet (affiché sur la page de démonstration)."
  type        = string
}

variable "environment" {
  description = "Environnement (affiché sur la page de démonstration)."
  type        = string
}

variable "app_subnet_ids" {
  description = "Subnets privés applicatifs (un par AZ)."
  type        = list(string)

  validation {
    condition     = length(var.app_subnet_ids) >= 2
    error_message = "Au moins deux subnets applicatifs (deux AZ) sont nécessaires."
  }
}

variable "app_sg_id" {
  description = "Security Group des instances."
  type        = string
}

variable "target_group_arn" {
  description = "Target Group de l'ALB."
  type        = string
}

variable "instance_profile_name" {
  description = "Profil d'instance IAM (LabInstanceProfile dans Learner Lab)."
  type        = string
}

variable "instance_type" {
  description = "Type d'instance EC2."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Types autorisés (budget Learner Lab) : t2.micro, t3.micro, t3.small, t3.medium."
  }
}

variable "min_size" {
  description = "Nombre minimal d'instances."
  type        = number
  default     = 2

  validation {
    condition     = var.min_size >= 2
    error_message = "min_size doit valoir au moins 2 (haute disponibilité sur deux AZ)."
  }
}

variable "max_size" {
  description = "Nombre maximal d'instances."
  type        = number
  default     = 4

  validation {
    condition     = var.max_size >= var.min_size && var.max_size <= 6
    error_message = "max_size doit être >= min_size et <= 6."
  }
}

variable "desired_capacity" {
  description = "Capacité souhaitée (null = min_size)."
  type        = number
  default     = null
}

variable "cpu_target" {
  description = "Cible de CPU moyen (%) pour la politique de scaling."
  type        = number
  default     = 50
}

variable "tags" {
  description = "Tags appliqués aux instances et volumes lancés par l'ASG."
  type        = map(string)
  default     = {}
}
