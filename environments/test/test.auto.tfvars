# test : validation fonctionnelle, proche de prod mais réduit
environment            = "test"
owner                  = "hamza"
vpc_cidr               = "10.30.0.0/16"
instance_type          = "t3.micro"
min_size               = 2
max_size               = 3
enable_nat_gateway     = false
db_instance_class      = "db.t3.micro"
db_backup_retention    = 1
db_deletion_protection = false
log_expiration_days    = 14
