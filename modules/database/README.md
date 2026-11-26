# Module `database`

RDS MySQL 8.0 dans un DB subnet group privé, non accessible depuis Internet.

- `publicly_accessible = false`, SG n'acceptant que le SG applicatif.
- Stockage gp3 chiffré (`storage_encrypted = true`).
- Groupe de paramètres : `utf8mb4` et `require_secure_transport = 1` (TLS obligatoire).
- **Mot de passe** généré par `random_password` : jamais dans Git, uniquement dans l'état chiffré (S3). Lecture : `terraform output -raw db_password`.
- `multi_az = false` par défaut (budget Learner Lab) ; à activer en production réelle.

## Entrées

| Nom | Type | Défaut | Description |
|---|---|---|---|
| `name_prefix` | string | — | Préfixe |
| `db_subnet_ids` | list(string) | — | ≥ 2 subnets privés |
| `db_sg_id` | string | — | SG de la base |
| `instance_class` | string | `db.t3.micro` | Validé |
| `allocated_storage` | number | `20` | 20 à 100 Go |
| `engine_version` | string | `8.0` | MySQL |
| `db_name` / `username` | string | `appdb` / `dbadmin` | |
| `multi_az` | bool | `false` | |
| `storage_encrypted` | bool | `true` | |
| `backup_retention_period` | number | `0` | Jours |
| `deletion_protection` | bool | `false` | |

## Sorties

`db_endpoint`, `db_port`, `db_name`, `db_username`, `db_password` (sensible)
