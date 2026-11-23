# Un bloc backend ne peut pas utiliser de variables.
# Remplacer "bucket" par la sortie state_bucket_name du dossier bootstrap/.
terraform {
  backend "s3" {
    bucket       = "REMPLACER-PAR-state_bucket_name"
    key          = "dev/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}
