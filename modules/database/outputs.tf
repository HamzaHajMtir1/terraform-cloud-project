output "db_endpoint" {
  description = "Adresse DNS de la base (résout vers une IP privée)."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Port de la base."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Nom de la base."
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "Utilisateur administrateur."
  value       = aws_db_instance.this.username
}

output "db_password" {
  description = "Mot de passe administrateur (masqué ; terraform output -raw db_password)."
  value       = random_password.master.result
  sensitive   = true
}
