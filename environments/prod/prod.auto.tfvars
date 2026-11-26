# prod : environnement final (dimensionné pour le budget Learner Lab)
# En production réelle : NAT par AZ, RDS Multi-AZ, deletion_protection = true
environment            = "prod"
owner                  = "hamza"
vpc_cidr               = "10.40.0.0/16"
instance_type          = "t3.micro"
min_size               = 2
max_size               = 4
enable_nat_gateway     = true
single_nat_gateway     = true
db_instance_class      = "db.t3.micro"
db_backup_retention    = 7
db_deletion_protection = false
log_expiration_days    = 90
