# Module `load-balancer`

Application Load Balancer public, Target Group HTTP avec health check, listener HTTP:80.

- `deregistration_delay = 30` : une instance arrêtée est retirée rapidement (test de panne).
- Health check : `GET /` toutes les 15 s, `Healthy` après 2 succès, `Unhealthy` après 2 échecs.
- `drop_invalid_header_fields = true` : rejette les en-têtes HTTP malformés.

## Entrées

| Nom | Type | Défaut | Description |
|---|---|---|---|
| `name_prefix` | string | — | ≤ 25 caractères (noms ALB/TG limités à 32) |
| `vpc_id` | string | — | VPC |
| `public_subnet_ids` | list(string) | — | ≥ 2 subnets publics |
| `alb_sg_id` | string | — | SG de l'ALB |
| `target_port` | number | `80` | Port des cibles |
| `health_check_path` | string | `/` | Chemin testé |

## Sorties

`alb_dns_name`, `alb_url`, `alb_arn`, `target_group_arn`

## Exemple

```hcl
module "load_balancer" {
  source            = "../../modules/load-balancer"
  name_prefix       = "cloud5-dev"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
}
```
