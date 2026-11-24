# -----------------------------------------------------------------------------
# Module network : VPC, subnets (public / app / db), Internet Gateway,
# NAT Gateway(s), VPC Endpoint S3 (Gateway) et tables de routage.
# -----------------------------------------------------------------------------

locals {
  # Transforme les listes en maps indexées par AZ pour utiliser for_each
  public_subnets = { for i, az in var.azs : az => var.public_subnet_cidrs[i] }
  app_subnets    = { for i, az in var.azs : az => var.app_subnet_cidrs[i] }
  db_subnets     = { for i, az in var.azs : az => var.db_subnet_cidrs[i] }

  # AZ qui reçoivent une NAT : la première seulement, ou toutes
  nat_azs = var.enable_nat_gateway ? (
    var.single_nat_gateway ? [var.azs[0]] : var.azs
  ) : []
}

# --- VPC ---------------------------------------------------------------------

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.name_prefix}-vpc" }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "${var.name_prefix}-igw" }
}

# --- Subnets -----------------------------------------------------------------

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false # aucune instance n'est lancée ici, sauf la NAT

  tags = {
    Name = "${var.name_prefix}-public-${each.key}"
    Tier = "public"
  }
}

resource "aws_subnet" "app" {
  for_each = local.app_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "${var.name_prefix}-app-${each.key}"
    Tier = "app"
  }
}

resource "aws_subnet" "db" {
  for_each = local.db_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "${var.name_prefix}-db-${each.key}"
    Tier = "db"
  }
}

# --- NAT Gateway(s) : sortie contrôlée des instances privées ------------------

resource "aws_eip" "nat" {
  for_each = toset(local.nat_azs)

  domain = "vpc"

  tags = { Name = "${var.name_prefix}-nat-eip-${each.key}" }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  for_each = toset(local.nat_azs)

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = { Name = "${var.name_prefix}-nat-${each.key}" }

  depends_on = [aws_internet_gateway.this]
}

# --- Routage public : 0.0.0.0/0 -> Internet Gateway ---------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "${var.name_prefix}-rt-public" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# --- Routage app : une table par AZ, 0.0.0.0/0 -> NAT ------------------------

resource "aws_route_table" "app" {
  for_each = local.app_subnets

  vpc_id = aws_vpc.this.id

  tags = { Name = "${var.name_prefix}-rt-app-${each.key}" }
}

resource "aws_route" "app_nat" {
  for_each = var.enable_nat_gateway ? local.app_subnets : {}

  route_table_id         = aws_route_table.app[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  # NAT unique -> toutes les AZ l'utilisent ; sinon chaque AZ utilise la sienne
  nat_gateway_id = aws_nat_gateway.this[var.single_nat_gateway ? var.azs[0] : each.key].id
}

resource "aws_route_table_association" "app" {
  for_each = aws_subnet.app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.app[each.key].id
}

# --- VPC Endpoint S3 (Gateway) : accès privé et gratuit à S3 -----------------
# Les dépôts dnf d'Amazon Linux 2023 sont hébergés sur Amazon S3 (buckets
# "al2023-repos-<région>-*"). Ce Gateway Endpoint ajoute une route vers S3 dans
# les tables de routage "app" : les instances privées installent donc nginx
# (dnf install nginx) SANS NAT Gateway. Contrairement à la NAT (facturée à
# l'heure + au Go traité), un Gateway Endpoint S3 est gratuit.

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_endpoint ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for rt in aws_route_table.app : rt.id]

  tags = { Name = "${var.name_prefix}-vpce-s3" }
}

# --- Routage db : aucune route vers Internet (isolé) -------------------------

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "${var.name_prefix}-rt-db" }
}

resource "aws_route_table_association" "db" {
  for_each = aws_subnet.db

  subnet_id      = each.value.id
  route_table_id = aws_route_table.db.id
}
