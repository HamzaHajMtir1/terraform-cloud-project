# Module `security`

Security Groups en chaîne : chaque couche n'accepte que le trafic de la couche précédente.

| SG | Entrant | Sortant |
|---|---|---|
| `alb-sg` | 80 (443 si `enable_https`) depuis 0.0.0.0/0 | `app_port` vers `app-sg` |
| `app-sg` | `app_port` depuis `alb-sg` | 443 (dépôts dnf via endpoint S3), `db_port` vers `db-sg` |
| `db-sg` | `db_port` depuis `app-sg` | aucun |

**IAM :** Learner Lab interdit la création de rôles. Le profil préexistant `LabInstanceProfile` (rôle `LabRole`) est transmis au module compute. En production, un rôle dédié limité à SSM et CloudWatch serait créé.

**Accès administratif :** aucun port SSH ouvert ; les instances sont immuables et remplacées par l'ASG.

## Entrées

| Nom | Type | Défaut | Description |
|---|---|---|---|
| `name_prefix` | string | — | Préfixe `<projet>-<env>` |
| `vpc_id` | string | — | VPC cible |
| `app_port` | number | `80` | Port des instances |
| `db_port` | number | `3306` | Port MySQL |
| `enable_https` | bool | `false` | Ouvre 443 sur l'ALB (certificat ACM requis) |
| `instance_profile_name` | string | `LabInstanceProfile` | Profil IAM des EC2 |

## Sorties

`alb_sg_id`, `app_sg_id`, `db_sg_id`, `instance_profile_name`

## Exemple

```hcl
module "security" {
  source      = "../../modules/security"
  name_prefix = "cloud5-dev"
  vpc_id      = module.network.vpc_id
}
```
