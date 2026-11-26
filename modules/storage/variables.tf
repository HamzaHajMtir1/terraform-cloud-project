variable "name_prefix" {
  description = "Préfixe des noms : <projet>-<environnement>."
  type        = string
}

variable "log_expiration_days" {
  description = "Suppression automatique des objets après N jours."
  type        = number
  default     = 30

  validation {
    condition     = var.log_expiration_days >= 1
    error_message = "log_expiration_days doit être >= 1."
  }
}

variable "noncurrent_expiration_days" {
  description = "Suppression des anciennes versions après N jours."
  type        = number
  default     = 7
}
