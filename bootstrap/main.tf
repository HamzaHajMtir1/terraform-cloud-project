# -----------------------------------------------------------------------------
# Bootstrap : configure le bucket S3 qui stockera les états Terraform
# (dev/test/prod). Cette configuration garde son propre état en LOCAL (c'est
# normal : le backend distant n'existe pas encore). On ne la lance qu'une fois.
#
# AWS Academy Learner Lab : une SCP du lab refuse
# s3:GetBucketObjectLockConfiguration. Or la ressource aws_s3_bucket appelle
# cette API à chaque lecture (création, refresh, import) et aucune version du
# provider AWS ne tolère ce refus. Le bucket est donc créé une fois avec l'AWS
# CLI (voir README, "Démarrage"), puis seulement lu ici (data source) et
# configuré par les ressources aws_s3_bucket_*, qui n'appellent jamais l'API
# Object Lock.
# -----------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "shared"
      ManagedBy   = "Terraform"
      Owner       = var.owner
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  # L'ID du compte rend le nom de bucket unique au niveau mondial
  state_bucket_name = "${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}"
}

# Bucket existant, créé par l'AWS CLI. Ce data source n'appelle que HeadBucket
# (et GetBucketWebsite, non bloquant) : rien qui soit refusé par le lab.
data "aws_s3_bucket" "tfstate" {
  bucket = local.state_bucket_name
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = data.aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }

  # Le bucket n'étant plus géré par Terraform, c'est ici qu'on empêche un
  # "terraform destroy" accidentel du bootstrap (historique des états)
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = data.aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = data.aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "tfstate" {
  bucket = data.aws_s3_bucket.tfstate.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Refuse toute connexion non chiffrée (HTTP) au bucket
resource "aws_s3_bucket_policy" "tfstate" {
  bucket = data.aws_s3_bucket.tfstate.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          data.aws_s3_bucket.tfstate.arn,
          "${data.aws_s3_bucket.tfstate.arn}/*"
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.tfstate]
}
