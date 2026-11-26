# Un bloc backend ne peut pas utiliser de variables.
# bucket = sortie state_bucket_name de bootstrap/
terraform {
  backend "s3" {
    bucket       = "cloud5-tfstate-820241894145"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
