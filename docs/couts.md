# Estimation des coûts (us-east-1, à la demande)

> Ordres de grandeur à confirmer avec [AWS Pricing Calculator](https://calculator.aws/). Le coût réel est relevé sur le compteur Learner Lab (« Used $X of $50 »).

| Ressource | Quantité | Coût approx. / heure |
|---|---|---|
| EC2 t3.micro | 2 | ~0,021 $ |
| Application Load Balancer (+ IPv4 publiques) | 1 | ~0,03 $ |
| RDS db.t3.micro MySQL (+ 20 Go gp3) | 1 | ~0,02 $ |
| NAT Gateway + IP élastique (prod uniquement) | 1 | ~0,05 $ + données |
| Endpoint S3 Gateway | 1 | gratuit |
| Buckets S3 (état + données) | 2 | négligeable |

| Environnement | Coût / heure | Coût / jour si oublié |
|---|---|---|
| dev / test (sans NAT) | ~0,07 $ | ~1,7 $ |
| prod (avec NAT) | ~0,12 $ | ~2,9 $ |

## Ressources générant des coûts

ALB, NAT Gateway, IP élastique, RDS (instance + stockage), EC2. **End Lab n'arrête que les EC2** : ALB, NAT et RDS continuent d'être facturés. `terraform destroy` est donc obligatoire après chaque démonstration.

## Suivi réel

| Date | Activité | Compteur Learner Lab |
|---|---|---|
| | Bootstrap + network | |
| | Stack dev complète + tests | |
| | test / prod (démo) | |
