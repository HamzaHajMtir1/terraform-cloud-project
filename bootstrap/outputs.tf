output "state_bucket_name" {
  description = "Nom du bucket à mettre dans le bloc backend de chaque environnement."
  value       = aws_s3_bucket.tfstate.bucket
}

output "state_bucket_arn" {
  description = "ARN du bucket d'état (utile pour les politiques IAM du pipeline)."
  value       = aws_s3_bucket.tfstate.arn
}
