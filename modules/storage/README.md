# Module `storage`

Bucket S3 de données (journaux, ressources, sauvegardes) : versioning, chiffrement SSE-S3, blocage de l'accès public, propriétaire imposé, HTTPS obligatoire, règles de cycle de vie.

**Contrainte Learner Lab :** la ressource Terraform `aws_s3_bucket` lit systématiquement `GetBucketObjectLockConfiguration`, action interdite par le SCP du lab. Le bucket est donc déclaré dans une **stack CloudFormation pilotée par Terraform** : Terraform lit la stack et non le bucket, et le bucket suit toujours `terraform apply` / `destroy`.

> Le bucket doit être vide pour que `destroy` réussisse (`aws s3 rm s3://<bucket> --recursive --include "*"` puis suppression des versions si besoin).

## Entrées

| Nom | Type | Défaut | Description |
|---|---|---|---|
| `name_prefix` | string | — | Préfixe |
| `log_expiration_days` | number | `30` | Expiration des objets |
| `noncurrent_expiration_days` | number | `7` | Expiration des anciennes versions |

## Sorties

`bucket_name`, `bucket_arn`
