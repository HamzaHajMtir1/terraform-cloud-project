variable "aws_region" {
  description = "Région AWS où créer le bucket du backend."
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Préfixe de nommage du projet."
  type        = string
  default     = "cloud5"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.project_name))
    error_message = "project_name : 3 à 20 caractères, minuscules, chiffres et tirets uniquement."
  }
}

variable "owner" {
  description = "Responsable des ressources (tag Owner)."
  type        = string
}
