# Choix de sécurité

## Réseau

- Instances applicatives et base dans des **subnets privés** sans IP publique.
- Subnets DB **isolés** : table de routage sans route vers Internet.
- Sortie contrôlée : en dev/test, **aucune route Internet** depuis les subnets app ; seul l'endpoint S3 est routé (paquets AL2023). En prod, NAT Gateway unique.

## Security Groups (chaînés)

| SG | Entrant | Sortant |
|---|---|---|
| ALB | 80 depuis 0.0.0.0/0 | 80 vers SG app |
| App | 80 depuis SG ALB uniquement | 443 (dépôts), 3306 vers SG DB |
| DB | 3306 depuis SG app uniquement | aucun |

## Accès administratif

Aucun port SSH ouvert, aucune paire de clés. Les instances sont immuables : une instance défaillante est remplacée par l'ASG. Le diagnostic passe par la console EC2 (journal système) et les health checks.

## Identités et secrets

| Élément | Mesure |
|---|---|
| Identifiants AWS | Dans `~/.aws/credentials` et les secrets GitHub, jamais dans Git ; temporaires (~4 h) |
| Mot de passe RDS | Généré par `random_password`, stocké uniquement dans l'état chiffré |
| Pipeline | Secrets masqués dans les journaux ; apply/destroy uniquement depuis `main` ; validation manuelle test/prod |
| Fichiers exclus de Git | `*.tfstate`, `.terraform/`, `terraform.tfvars`, plans |
| IAM des EC2 | `LabInstanceProfile` imposé par Learner Lab (création de rôles interdite). En production : rôle dédié limité à SSM et CloudWatch |
| IMDS | IMDSv2 obligatoire (protection SSRF) |

## Chiffrement

| Donnée | Chiffrement |
|---|---|
| État Terraform | SSE-S3 + `encrypt = true` + politique refusant HTTP + versioning |
| RDS | Stockage chiffré (clé aws/rds) + `require_secure_transport = 1` (TLS) |
| Bucket de données | SSE-S3, accès public bloqué, HTTPS obligatoire |

## Contraintes Learner Lab et adaptations

| Contrainte | Adaptation |
|---|---|
| Création de rôles IAM / fournisseur OIDC interdite | `LabRole` pour les EC2 ; secrets GitHub temporaires pour le pipeline |
| SCP interdisant `s3:GetBucketObjectLockConfiguration` (lu par `aws_s3_bucket`) | Bucket d'état créé par CLI + data source ; bucket de données via stack CloudFormation pilotée par Terraform |
| Régions limitées | `us-east-1` |
| Budget 50 $ | Pas de NAT en dev/test, RDS mono-AZ, destruction systématique |

## Limites et améliorations

HTTPS avec ACM et nom de domaine · OIDC pour le pipeline · RDS Multi-AZ · NAT par AZ · AWS WAF devant l'ALB · rôle IAM dédié · Secrets Manager pour le mot de passe RDS · journaux d'accès ALB vers S3.
