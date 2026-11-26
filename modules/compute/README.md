# Module `compute`

Launch Template Amazon Linux 2023 + Auto Scaling Group réparti sur les subnets applicatifs + politique de scaling sur le CPU.

- **AMI** : dernière Amazon Linux 2023 x86_64 (data source).
- **IMDSv2 obligatoire** (`http_tokens = "required"`).
- **user_data** (`user_data.sh.tftpl`) : installe nginx depuis les dépôts AL2023 via l'endpoint S3 (pas d'accès Internet) et publie une page affichant l'instance, la zone et l'IP privée. Repli automatique sur le serveur HTTP Python si l'installation échoue.
- **ASG** : `health_check_type = "ELB"` (une instance jugée Unhealthy par l'ALB est remplacée), `instance_refresh` progressif.
- **Scaling** : target tracking sur `ASGAverageCPUUtilization` (50 % par défaut).

## Entrées

| Nom | Type | Défaut | Description |
|---|---|---|---|
| `name_prefix` | string | — | Préfixe |
| `project_name`, `environment` | string | — | Affichés sur la page |
| `app_subnet_ids` | list(string) | — | ≥ 2 subnets privés |
| `app_sg_id` | string | — | SG des instances |
| `target_group_arn` | string | — | Target Group de l'ALB |
| `instance_profile_name` | string | — | Profil IAM |
| `instance_type` | string | `t3.micro` | Validé (types économiques) |
| `min_size` / `max_size` | number | `2` / `4` | min ≥ 2, max ≥ min |
| `desired_capacity` | number | `null` | null = min_size |
| `cpu_target` | number | `50` | Cible CPU (%) |
| `tags` | map(string) | `{}` | Tags des instances |

## Sorties

`asg_name`, `launch_template_id`, `ami_id`
