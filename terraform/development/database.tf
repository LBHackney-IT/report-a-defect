locals {
  database_name = "reportadefect"
  database_port = 5432
  database_url  = "postgres://${aws_secretsmanager_secret_version.db_username.secret_string}:${aws_secretsmanager_secret_version.db_password.secret_string}@${module.lbh-db-postgres.instance_id}.eu-west-2.rds.amazonaws.com:${local.database_port}/${local.database_name}"
}

# Get VPC and Subnets
data "aws_vpc" "development_vpc" {
  tags = {
    Name = "housing-dev"
  }
}
data "aws_subnets" "development_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.development_vpc.id]
  }
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_subnets" "development_public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.development_vpc.id]
  }
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

# Credentials

# DB Username
resource "aws_secretsmanager_secret" "db_username" {
  name = "report-a-defect-db-username"
}
resource "aws_secretsmanager_secret_version" "db_username" {
  secret_id     = aws_secretsmanager_secret.db_username.id
  secret_string = "report_a_defect_admin"
}

# DB Password
resource "random_password" "db_password" {
  length  = 16
  special = false
}
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "report-a-defect-db-password"
  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

# DB URL
resource "aws_secretsmanager_secret" "database_url" {
  name = "report-a-defect-database-url"
}
resource "aws_secretsmanager_secret_version" "database_url_version" {
  secret_id     = aws_secretsmanager_secret.database_url.id
  secret_string = jsonencode({ DATABASE_URL = local.database_url })
}

module "lbh-db-postgres" {
  source                  = "github.com/LBHackney-IT/aws-hackney-common-terraform//modules/database/postgres?ref=15d6da7fb25f6925d9e33530b8245a3a300053ac"
  project_name            = "report-a-defect"
  environment_name        = local.environment_name
  vpc_id                  = data.aws_vpc.development_vpc.id
  db_identifier           = "report-a-defect"
  db_name                 = local.database_name
  db_port                 = local.database_port
  subnet_ids              = data.aws_subnets.development_private_subnets.ids
  db_engine               = "postgres"
  db_engine_version       = "15.8"
  db_instance_class       = "db.t3.micro"
  db_parameter_group_name = "default.postgres15"
  db_allocated_storage    = 10
  maintenance_window      = "sun:01:00-sun:01:30"
  db_username             = aws_secretsmanager_secret_version.db_username.secret_string
  db_password             = aws_secretsmanager_secret_version.db_password.secret_string
  storage_encrypted       = true
  multi_az                = false
  publicly_accessible     = false
}