# Résultats des tests obligatoires

Environnement : dev · Date : ____ · Captures : `docs/captures/`

| # | Test | Procédure | Résultat attendu | Résultat obtenu | Capture |
|---|---|---|---|---|---|
| 1 | Format | `terraform fmt -check -recursive` | Aucune différence | | `01-fmt.png` |
| 2 | Validation | `terraform validate` | Success | | `02-validate.png` |
| 3 | Plan | `terraform plan` / pipeline | Plan sans erreur | | `03-pipeline.png` |
| 4 | Accès Web | Ouvrir `terraform output alb_url` | Page disponible | | `04-page-web.png` |
| 5 | Répartition | `scripts/test-repartition.ps1` | ≥ 2 instances | | `05-repartition.png` |
| 6 | Panne | `scripts/test-panne.ps1` | Service toujours disponible, instance remplacée | | `06-panne.png` |
| 7 | Auto Scaling | `terraform apply -var desired_capacity=3` | 3 instances | | `07-scaling.png` |
| 8 | Sécurité DB | `scripts/test-securite-db.ps1` | Accès refusé, IP privée | | `08-db.png` |
| 9 | Destruction | `terraform destroy` | Ressources supprimées | | `09-destroy.png` |

## Captures demandées (cahier des charges, section 26)

- [ ] Pipeline avec fmt, validate et plan réussis
- [ ] VPC et sous-réseaux
- [ ] Load Balancer et Target Group sain
- [ ] Auto Scaling Group et instances
- [ ] RDS dans les sous-réseaux privés
- [ ] Backend distant (bucket d'état avec `dev/terraform.tfstate`)
- [ ] Page Web accessible
- [ ] Résultat du test de panne
