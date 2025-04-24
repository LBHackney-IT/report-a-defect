# Get existing VPC and Subnets, create new subnet & security group
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
resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.database_name}-db-subnet-${var.environment_name}"
  subnet_ids = data.aws_subnets.development_private_subnets.ids

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "db_security_group" {
  vpc_id      = data.aws_vpc.development_vpc.id
  name_prefix = "allow_${var.database_name}_db_traffic"

  egress {
    description = "allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    description = "${var.database_name}-${var.environment_name}"
    from_port   = var.database_port
    to_port     = var.database_port
    protocol    = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  lifecycle { ignore_changes = [ingress] }
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
locals {
  database_url = "postgres://${aws_secretsmanager_secret_version.db_username.secret_string}:${aws_secretsmanager_secret_version.db_password.secret_string}@${aws_db_instance.lbh-db.identifier}.eu-west-2.rds.amazonaws.com:${var.database_port}/${var.database_name}"
}
resource "aws_secretsmanager_secret" "database_url" {
  name = "report-a-defect-database-url"
}
resource "aws_secretsmanager_secret_version" "database_url_version" {
  secret_id     = aws_secretsmanager_secret.database_url.id
  secret_string = local.database_url
}

# DB Instance
resource "aws_db_instance" "lbh-db" {
  identifier                  = "report-a-defect-db-${var.environment_name}"
  engine                      = "postgres"
  engine_version              = "15.8"
  instance_class              = "db.t3.micro"
  allocated_storage           = 10
  max_allocated_storage       = 0
  ca_cert_identifier          = "rds-ca-rsa2048-g1"
  storage_type                = "gp2" //ssd
  port                        = var.database_port
  maintenance_window          = "sun:01:00-sun:01:30"
  backup_window               = "00:01-00:31"
  username                    = aws_secretsmanager_secret_version.db_username.secret_string
  password                    = aws_secretsmanager_secret_version.db_password.secret_string
  vpc_security_group_ids      = [aws_security_group.db_security_group.id]
  db_subnet_group_name        = aws_db_subnet_group.db_subnets.name
  db_name                     = var.database_name
  monitoring_interval         = 0
  backup_retention_period     = 30
  storage_encrypted           = true
  multi_az                    = false
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  parameter_group_name        = "default.postgres15"

  apply_immediately   = false
  publicly_accessible = false

  # Deletion / Restore related
  deletion_protection   = false
  skip_final_snapshot   = true
  copy_tags_to_snapshot = false
}