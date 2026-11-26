# terraform-cloud-project

Plateforme Web hautement disponible sur AWS, entièrement décrite en Terraform (modules réutilisables, environnements dev / test / prod) et déployée par un pipeline GitHub Actions.

![Architecture](docs/architecture.png)

## Architecture

| Couche | Ressources | Subnets |
|---|---|---|
| Accès | Internet Gateway, Application Load Balancer | publics (2 AZ) |
| Application | Launch Template, Auto Scaling Group (2 à 4 EC2 Amazon Linux 2023 + nginx) | privés app (2 AZ) |
| Données | RDS MySQL 8.0 chiffré, non public | privés db (2 AZ) |
| Stockage | Bucket S3 versionné et chiffré | — |
| Sortie contrôlée | VPC Gateway Endpoint S3 (NAT Gateway en prod) | — |
| État Terraform | Bucket S3 chiffré, versionné, verrouillage natif | — |

Détails : [docs/architecture.md](docs/architecture.md) · Sécurité : [docs/securite.md](docs/securite.md) · Coûts : [docs/couts.md](docs/couts.md) · Tests : [docs/tests.md](docs/tests.md)

## Structure du dépôt

```
.github/workflows/terraform.yml   pipeline CI/CD
bootstrap/                        configuration du bucket d'état
modules/                          network, security, load-balancer, compute, database, storage
environments/{dev,test,prod}/     composition des modules + <env>.auto.tfvars + backend
scripts/                          création du bucket, secrets GitHub, tests
docs/                             architecture, sécurité, coûts, tests, captures
```

## Prérequis

- Terraform ≥ 1.10 (verrouillage natif S3 `use_lockfile`)
- AWS CLI v2
- Git, et GitHub CLI (`gh`) pour mettre à jour les secrets du pipeline
- AWS Academy Learner Lab (région `us-east-1`, budget 50 $)

## Authentification (sans secret en clair)

Les identifiants Learner Lab sont temporaires (~4 h) et changent à chaque session :

```powershell
# Start Lab > AWS Details > AWS CLI: Show
aws configure set aws_access_key_id     <valeur>
aws configure set aws_secret_access_key <valeur>
aws configure set aws_session_token     <valeur>
aws configure set region us-east-1
aws sts get-caller-identity
```

Les identifiants restent dans `~/.aws/credentials`, jamais dans le dépôt. Pour le pipeline : `scripts/update-gh-secrets.ps1`.

## Déploiement

### 1. Backend (une seule fois)

```powershell
powershell -ExecutionPolicy Bypass -File scripts\create-state-bucket.ps1
cd bootstrap
copy terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
terraform output state_bucket_name   # à reporter dans environments/*/backend.tf
```

### 2. Environnement

```powershell
cd environments\dev
terraform init
terraform fmt -check -recursive ..\..
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output alb_url
```

### 3. Destruction (obligatoire après chaque démonstration)

```powershell
terraform destroy
```

## Modules

| Module | Rôle | Doc |
|---|---|---|
| network | VPC, subnets public/app/db, IGW, endpoint S3, NAT optionnelle, routage | [README](modules/network/README.md) |
| security | Security Groups ALB → App → DB, profil IAM | [README](modules/security/README.md) |
| load-balancer | ALB, Target Group, health check, listener | [README](modules/load-balancer/README.md) |
| compute | Launch Template, user_data, ASG, scaling CPU | [README](modules/compute/README.md) |
| database | RDS MySQL, subnet group, paramètres, mot de passe généré | [README](modules/database/README.md) |
| storage | Bucket S3 versionné, chiffré, cycle de vie | [README](modules/storage/README.md) |

## Variables principales

| Variable | dev | test | prod |
|---|---|---|---|
| `vpc_cidr` | 10.20.0.0/16 | 10.30.0.0/16 | 10.40.0.0/16 |
| `instance_type` | t3.micro | t3.micro | t3.micro |
| `min_size` / `max_size` | 2 / 3 | 2 / 3 | 2 / 4 |
| `enable_nat_gateway` | false | false | true |
| `db_instance_class` | db.t3.micro | db.t3.micro | db.t3.micro |
| `db_backup_retention` | 0 | 1 | 7 |

Valeurs dans `environments/<env>/<env>.auto.tfvars` (versionnées, sans secret). Valeurs personnelles éventuelles : `terraform.tfvars` (ignoré par Git, voir `terraform.tfvars.example`).

## Sorties principales

`alb_url`, `asg_name`, `db_endpoint`, `db_password` (sensible), `data_bucket`, `vpc_id`, IDs des subnets.

## Conventions

- Noms : `<projet>-<environnement>-<ressource>` (ex. `cloud5-dev-alb`).
- Tags obligatoires via `default_tags` : `Project`, `Environment`, `Owner`, `ManagedBy`.
- Variables en snake_case, typées, décrites et validées.
- Branche `main` protégée : toute modification passe par une Pull Request.

## Pipeline CI/CD

Fichier : [.github/workflows/terraform.yml](.github/workflows/terraform.yml)

| Déclencheur | Étapes |
|---|---|
| Pull Request | fmt -check, init, validate (tous les environnements), plan dev publié en commentaire de la PR et en artefact |
| Push sur `main` | idem + apply dev si la variable de dépôt `AUTO_APPLY_DEV = true` |
| Manuel (Actions > Terraform > Run workflow) | plan, apply ou destroy sur dev, test ou prod |

- `apply` et `destroy` ne s'exécutent que depuis `main` (branche protégée).
- `test` et `prod` utilisent des GitHub Environments avec validation manuelle (*Required reviewers*).
- `apply` exécute exactement le plan produit et conservé à l'étape précédente.
- Secrets : `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` (renouvelés à chaque session par `scripts/update-gh-secrets.ps1`). La fédération OIDC, préférable, est impossible dans Learner Lab.

## Tests

```powershell
powershell -ExecutionPolicy Bypass -File scripts\test-repartition.ps1
powershell -ExecutionPolicy Bypass -File scripts\test-panne.ps1
powershell -ExecutionPolicy Bypass -File scripts\test-securite-db.ps1
```

Résultats : [docs/tests.md](docs/tests.md).

## Coûts et limites connus

- Stack complète ≈ 0,07 à 0,12 $/h selon la NAT (détail : [docs/couts.md](docs/couts.md)). Détruire après chaque démonstration : *End Lab* n'arrête que les EC2.
- HTTP uniquement (pas de nom de domaine pour un certificat ACM).
- RDS mono-AZ et une seule NAT en prod (budget).
- Rôle IAM imposé `LabRole` (création de rôles interdite) : moindre privilège non applicable dans le lab.
- `aws_s3_bucket` bloquée par le SCP du lab : bucket d'état créé par CLI, bucket de données via CloudFormation.

## Dépannage

| Symptôme | Cause / solution |
|---|---|
| `ExpiredToken` / `InvalidClientTokenId` | Session expirée : recopier les 3 valeurs, puis `scripts/update-gh-secrets.ps1` |
| `AccessDenied ... service control policy` | Restriction Learner Lab (voir Readme du lab) |
| `Error acquiring the state lock` | Session interrompue pendant un apply : `terraform force-unlock <ID>` |
| Target Group `Unhealthy` | Attendre ~3 min (user_data) ; vérifier l'endpoint S3 et le SG app (443 sortant) |
| `destroy` bloqué sur la stack storage | Vider le bucket de données puis relancer `terraform destroy` |
| `BucketAlreadyExists` au bootstrap | Bucket déjà créé : le bootstrap utilise une data source, lancer simplement `terraform apply` |
