variable "name_prefix" {
  description = "Préfixe des noms : <projet>-<environnement>."
  type        = string
}

variable "db_subnet_ids" {
  description = "Subnets privés base de données (au moins 2 AZ)."
  type        = list(string)

  validation {
    condition     = length(var.db_subnet_ids) >= 2
    error_message = "Un DB subnet group RDS nécessite au moins deux AZ."
  }
}

variable "db_sg_id" {
  description = "Security Group de la base."
  type        = string
}

variable "instance_class" {
  description = "Classe d'instance RDS."
  type        = string
  default     = "db.t3.micro"

  validation {
    condition     = contains(["db.t3.micro", "db.t3.small", "db.t4g.micro"], var.instance_class)
    error_message = "Classes autorisées (budget Learner Lab) : db.t3.micro, db.t3.small, db.t4g.micro."
  }
}

variable "allocated_storage" {
  description = "Stockage alloué (Go)."
  type        = number
  default     = 20

  validation {
    condition     = var.allocated_storage >= 20 && var.allocated_storage <= 100
    error_message = "allocated_storage doit être compris entre 20 et 100 Go."
  }
}

variable "engine_version" {
  description = "Version majeure de MySQL."
  type        = string
  default     = "8.0"
}

variable "db_name" {
  description = "Nom de la base créée."
  type        = string
  default     = "appdb"
}

variable "username" {
  description = "Utilisateur administrateur."
  type        = string
  default     = "dbadmin"
}

variable "multi_az" {
  description = "Instance de secours dans une autre AZ (double le coût)."
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Chiffrement du stockage RDS (clé AWS gérée aws/rds)."
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Durée de rétention des sauvegardes automatiques (jours, 0 = désactivé)."
  type        = number
  default     = 0
}

variable "deletion_protection" {
  description = "Empêche la suppression de la base."
  type        = bool
  default     = false
}
