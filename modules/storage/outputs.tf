output "bucket_name" {
  description = "Nom du bucket S3."
  value       = aws_cloudformation_stack.bucket.outputs["BucketName"]
}

output "bucket_arn" {
  description = "ARN du bucket S3."
  value       = aws_cloudformation_stack.bucket.outputs["BucketArn"]
}
