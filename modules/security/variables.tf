variable "name_prefix" {
  description = "Préfixe des noms : <projet>-<environnement>."
  type        = string
}

variable "vpc_id" {
  description = "ID du VPC où créer les Security Groups."
  type        = string
}

variable "app_port" {
  description = "Port HTTP des instances applicatives."
  type        = number
  default     = 80

  validation {
    condition     = var.app_port > 0 && var.app_port < 65536
    error_message = "app_port doit être un port TCP valide."
  }
}

variable "db_port" {
  description = "Port de la base de données (3306 pour MySQL)."
  type        = number
  default     = 3306
}

variable "enable_https" {
  description = "Ouvre le port 443 sur l'ALB (nécessite un certificat ACM, donc un nom de domaine)."
  type        = bool
  default     = false
}

variable "instance_profile_name" {
  description = "Profil d'instance IAM des EC2. Learner Lab interdit la création de rôles : LabInstanceProfile est imposé."
  type        = string
  default     = "LabInstanceProfile"
}
