output "alb_sg_id" {
  description = "Security Group de l'ALB."
  value       = aws_security_group.alb.id
}

output "app_sg_id" {
  description = "Security Group des instances applicatives."
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "Security Group de la base de données."
  value       = aws_security_group.db.id
}

output "instance_profile_name" {
  description = "Profil d'instance IAM à attacher aux EC2."
  value       = var.instance_profile_name
}
