output "asg_name" {
  description = "Nom de l'Auto Scaling Group."
  value       = aws_autoscaling_group.this.name
}

output "launch_template_id" {
  description = "ID du Launch Template."
  value       = aws_launch_template.this.id
}

output "ami_id" {
  description = "AMI Amazon Linux 2023 utilisée."
  value       = data.aws_ami.al2023.id
}
