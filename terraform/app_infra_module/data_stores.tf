# Defines data storage services like RDS (Postgres) and ElastiCache (Redis).
# These services are connected to ECS for application data storage and caching.

# Postgres Credentials
resource "aws_secretsmanager_secret" "db_username" {
  name                    = "report-a-defect-db-username"
  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "db_username" {
  secret_id     = aws_secretsmanager_secret.db_username.id
  secret_string = "report_a_defect_admin"
}
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
resource "aws_secretsmanager_secret" "database_url" {
  name                    = "report-a-defect-database-url"
  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "database_url_version" {
  secret_id     = aws_secretsmanager_secret.database_url.id
  secret_string = local.database_url
}

# Postgres DB Instance
resource "aws_db_instance" "lbh-db" {
  identifier                  = "report-a-defect-db-${var.environment_name}"
  engine                      = "postgres"
  engine_version              = "15.8"
  instance_class              = "db.t3.micro"
  allocated_storage           = 10
  max_allocated_storage       = 0
  ca_cert_identifier          = "rds-ca-rsa2048-g1"
  storage_type                = "gp2" //ssd
  port                        = local.database_port
  maintenance_window          = "sun:01:00-sun:01:30"
  backup_window               = "00:01-00:31"
  username                    = aws_secretsmanager_secret_version.db_username.secret_string
  password                    = aws_secretsmanager_secret_version.db_password.secret_string
  vpc_security_group_ids      = [aws_security_group.db_security_group.id]
  db_subnet_group_name        = aws_db_subnet_group.db_subnets.name
  db_name                     = local.database_name
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

# Redis Instance
resource "aws_elasticache_cluster" "lbh-redis" {
  cluster_id           = "report-a-defect-redis-${var.environment_name}"
  engine               = "redis"
  engine_version       = "7.0"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  port                 = local.redis_port
  parameter_group_name = "default.redis7"
  security_group_ids   = [aws_security_group.db_security_group.id]
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnets.name
}
resource "aws_ssm_parameter" "redis_url" {
  name      = "/report-a-defect/${var.environment_name}/redis_url"
  type      = "String"
  value     = "redis://${aws_elasticache_cluster.lbh-redis.cache_nodes.0.address}:${local.redis_port}"
  overwrite = true
}