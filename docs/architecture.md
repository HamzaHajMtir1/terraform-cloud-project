# Architecture

```mermaid
flowchart TB
    user([Utilisateurs Internet]) --> igw[Internet Gateway]
    subgraph vpc[VPC 10.20.0.0/16 - us-east-1]
        igw --> alb[Application Load Balancer<br/>subnets publics A/B]
        subgraph azA[AZ A]
            ec2a[EC2 nginx<br/>10.20.11.0/24]
            dba[(RDS MySQL<br/>10.20.21.0/24)]
        end
        subgraph azB[AZ B]
            ec2b[EC2 nginx<br/>10.20.12.0/24]
            dbb[subnet DB B<br/>10.20.22.0/24]
        end
        alb --> ec2a
        alb --> ec2b
        ec2a --> dba
        ec2b --> dba
        ec2a -. dnf .-> vpce[Endpoint S3]
        ec2b -. dnf .-> vpce
    end
    vpce --> s3repo[(Dépôts Amazon Linux 2023 sur S3)]
    asg{{Auto Scaling Group 2-4}} --- ec2a
    asg --- ec2b
    s3data[(Bucket S3 données)]
    s3state[(Bucket S3 état Terraform)]
```

## Flux de déploiement

```
Développeur -> branche -> Pull Request -> GitHub Actions
   fmt -check -> init -> validate -> plan (commentaire PR + artefact)
   merge sur main (protégée) -> apply manuel (validation pour test/prod)
   Terraform -> AWS : réseau, sécurité, ALB, Auto Scaling, RDS, S3
   État -> s3://cloud5-tfstate-<compte>/<env>/terraform.tfstate (chiffré, versionné, verrouillé)
```

## Plan d'adressage (dev)

| Composant | CIDR |
|---|---|
| VPC | 10.20.0.0/16 |
| Public A / B | 10.20.1.0/24, 10.20.2.0/24 |
| App A / B | 10.20.11.0/24, 10.20.12.0/24 |
| DB A / B | 10.20.21.0/24, 10.20.22.0/24 |

test : 10.30.0.0/16 · prod : 10.40.0.0/16 (mêmes offsets, dérivés par `cidrsubnet`).
