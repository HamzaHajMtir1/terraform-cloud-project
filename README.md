# terraform-cloud-project

Plateforme Web hautement disponible sur AWS (VPC multi-AZ, ALB, Auto Scaling, RDS, S3), décrite en modules Terraform et déployée par un pipeline CI/CD.

> Document en cours : complété au fil des modules.

## Prérequis

- Terraform >= 1.10
- AWS CLI v2
- AWS Academy Learner Lab (région `us-east-1`, budget 50 $)

## Authentification (Learner Lab)

1. **Start Lab**, puis **AWS Details**, puis **AWS CLI : Show**.
2. Coller le bloc affiché (avec `aws_session_token`) dans `~/.aws/credentials` (`%USERPROFILE%\.aws\credentials` sous Windows), jamais dans le dépôt. Ce bloc ne contient pas de région : la fixer une fois pour l'AWS CLI avec `aws configure set region us-east-1` (Terraform, lui, utilise `aws_region`).
3. Vérifier : `aws sts get-caller-identity`.

Les identifiants expirent à chaque session (~4 h) : les recopier après chaque **Start Lab**.

Contraintes du lab :

- la création de rôles IAM est interdite, d'où l'utilisation de `LabRole` / `LabInstanceProfile` (via data sources) dans les modules suivants ;
- seules les régions autorisées par le lab sont utilisables.

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

## Coûts

- NAT Gateway désactivée en dev (`enable_nat_gateway = false`) : ~0,05 $/h évité (NAT 0,045 $/h + IP élastique 0,005 $/h), plus 0,045 $/Go de données traitées.
- VPC Endpoint S3 (Gateway) gratuit : les dépôts dnf d'Amazon Linux 2023 sont hébergés sur S3, donc nginx s'installe sans NAT.
- `terraform destroy` obligatoire avant **End Lab** : la NAT Gateway, l'ALB et RDS continuent d'être facturés après la fin de la session.
- Le bucket d'état créé par `bootstrap/` (protégé par `prevent_destroy`) peut rester : son coût est négligeable.

## Modules

| Module | État |
|---|---|
| network | ✅ |
| security | à faire |
| load-balancer | à faire |
| compute | à faire |
| database | à faire |
| storage | à faire |
