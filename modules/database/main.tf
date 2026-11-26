# -----------------------------------------------------------------------------
# Module database : RDS MySQL dans des subnets privés, non accessible
# depuis Internet. Le mot de passe est généré par Terraform : il n'apparaît
# jamais dans Git, seulement dans l'état (chiffré dans S3).
# -----------------------------------------------------------------------------

resource "random_password" "master" {
  length           = 20
  special          = true
  override_special = "!#$%^&*()-_=+[]{}:?"
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnets"
  subnet_ids = var.db_subnet_ids

  tags = { Name = "${var.name_prefix}-db-subnets" }
}

resource "aws_db_parameter_group" "this" {
  name   = "${var.name_prefix}-mysql80"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  # Refuse les connexions non chiffrées (TLS obligatoire)
  parameter {
    name  = "require_secure_transport"
    value = "1"
  }

  tags = { Name = "${var.name_prefix}-mysql80" }
}

resource "aws_db_instance" "this" {
  identifier     = "${var.name_prefix}-db"
  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = var.storage_encrypted

  db_name  = var.db_name
  username = var.username
  password = random_password.master.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  parameter_group_name   = aws_db_parameter_group.this.name
  vpc_security_group_ids = [var.db_sg_id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  backup_retention_period    = var.backup_retention_period
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = true
  apply_immediately          = true
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  tags = { Name = "${var.name_prefix}-db" }
}
