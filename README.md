# terraform-cloud-project

Plateforme Web hautement disponible sur AWS (VPC multi-AZ, ALB, Auto Scaling, RDS, S3), décrite en modules Terraform et déployée par un pipeline CI/CD.

> Document en cours : complété au fil des modules.

## Prérequis

- Terraform >= 1.10
- AWS CLI v2 configurée (`aws configure` ou SSO), sans clé dans le dépôt
- Un compte AWS avec les droits nécessaires

## Démarrage

```bash
# 1. Bootstrap du backend (une seule fois)
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
terraform output state_bucket_name

# 2. Environnement dev
cd ../environments/dev
# -> mettre le nom du bucket dans backend.tf
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -check -recursive ../..
terraform validate
terraform plan -out=tfplan
terraform apply tfplan

# 3. Destruction après la démo
terraform destroy
```

## Modules

| Module | État |
|---|---|
| network | ✅ |
| security | à faire |
| load-balancer | à faire |
| compute | à faire |
| database | à faire |
| storage | à faire |
