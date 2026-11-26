# Module `network`

Crée le réseau de la plateforme : VPC sur plusieurs AZ, subnets publics / applicatifs / base de données, Internet Gateway, NAT Gateway(s) et tables de routage.

| Subnet | Route par défaut | Usage |
|---|---|---|
| public | Internet Gateway | ALB, NAT Gateway |
| app | NAT Gateway | Instances EC2 (Auto Scaling) |
| db | aucune (isolé) | RDS |

## Entrées

| Nom | Type | Défaut | Description |
|---|---|---|---|
| `name_prefix` | string | — | Préfixe `<projet>-<env>` |
| `vpc_cidr` | string | `10.20.0.0/16` | CIDR du VPC |
| `azs` | list(string) | — | Au moins 2 AZ |
| `public_subnet_cidrs` | list(string) | — | Un CIDR par AZ |
| `app_subnet_cidrs` | list(string) | — | Un CIDR par AZ |
| `db_subnet_cidrs` | list(string) | — | Un CIDR par AZ |
| `enable_nat_gateway` | bool | `true` | Sortie Internet des subnets app (payant) |
| `single_nat_gateway` | bool | `true` | Une seule NAT (dev/test) ou une par AZ (prod) |
| `enable_s3_endpoint` | bool | `true` | Gateway Endpoint S3 gratuit (paquets AL2023 sans NAT) |

## Sorties

`vpc_id`, `vpc_cidr`, `public_subnet_ids`, `app_subnet_ids`, `db_subnet_ids`, `nat_gateway_ids`

## Exemple

```hcl
module "network" {
  source = "../../modules/network"

  name_prefix         = "cloud5-dev"
  vpc_cidr            = "10.20.0.0/16"
  azs                 = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs = ["10.20.1.0/24", "10.20.2.0/24"]
  app_subnet_cidrs    = ["10.20.11.0/24", "10.20.12.0/24"]
  db_subnet_cidrs     = ["10.20.21.0/24", "10.20.22.0/24"]
  single_nat_gateway  = true
}
```

## Sortie contrôlée sans NAT

Les subnets applicatifs n'ont aucune route vers Internet en dev/test : seul le Gateway Endpoint S3 (gratuit) est routé. Il suffit pour installer les paquets Amazon Linux 2023, dont les dépôts sont hébergés sur S3. La NAT Gateway reste disponible (`enable_nat_gateway = true`, activée en prod).

## Coûts

Chaque NAT Gateway est facturée à l'heure + au volume de données, et son IP élastique aussi. Détruire l'environnement après chaque démonstration.
