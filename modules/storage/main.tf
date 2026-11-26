# -----------------------------------------------------------------------------
# Module storage : bucket S3 (journaux, ressources, sauvegardes).
#
# Contrainte Learner Lab : la ressource aws_s3_bucket est bloquée par le SCP
# (s3:GetBucketObjectLockConfiguration). Le bucket est donc décrit dans une
# stack CloudFormation pilotée par Terraform : Terraform lit la stack, pas le
# bucket. Le cycle de vie reste lié à terraform apply / destroy.
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

locals {
  bucket_name = "${var.name_prefix}-data-${data.aws_caller_identity.current.account_id}"
}

resource "aws_cloudformation_stack" "bucket" {
  name = "${var.name_prefix}-storage"

  template_body = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09"
    Description              = "Bucket S3 ${var.name_prefix} (gere par Terraform)"

    Resources = {
      DataBucket = {
        Type = "AWS::S3::Bucket"
        Properties = {
          BucketName = local.bucket_name

          VersioningConfiguration = { Status = "Enabled" }

          BucketEncryption = {
            ServerSideEncryptionConfiguration = [{
              ServerSideEncryptionByDefault = { SSEAlgorithm = "AES256" }
            }]
          }

          PublicAccessBlockConfiguration = {
            BlockPublicAcls       = true
            BlockPublicPolicy     = true
            IgnorePublicAcls      = true
            RestrictPublicBuckets = true
          }

          OwnershipControls = {
            Rules = [{ ObjectOwnership = "BucketOwnerEnforced" }]
          }

          LifecycleConfiguration = {
            Rules = [{
              Id                             = "expiration"
              Status                         = "Enabled"
              ExpirationInDays               = var.log_expiration_days
              NoncurrentVersionExpiration    = { NoncurrentDays = var.noncurrent_expiration_days }
              AbortIncompleteMultipartUpload = { DaysAfterInitiation = 1 }
            }]
          }
        }
      }

      DataBucketPolicy = {
        Type = "AWS::S3::BucketPolicy"
        Properties = {
          Bucket = { Ref = "DataBucket" }
          PolicyDocument = {
            Version = "2012-10-17"
            Statement = [{
              Sid       = "DenyInsecureTransport"
              Effect    = "Deny"
              Principal = "*"
              Action    = "s3:*"
              Resource = [
                { "Fn::GetAtt" = ["DataBucket", "Arn"] },
                { "Fn::Sub" = "$${DataBucket.Arn}/*" }
              ]
              Condition = { Bool = { "aws:SecureTransport" = "false" } }
            }]
          }
        }
      }
    }

    Outputs = {
      BucketName = { Value = { Ref = "DataBucket" } }
      BucketArn  = { Value = { "Fn::GetAtt" = ["DataBucket", "Arn"] } }
    }
  })
}
