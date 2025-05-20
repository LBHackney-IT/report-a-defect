# Defines the network layer including VPC, subnets, and security groups.
# This file sets up the networking required for ECS and other services to communicate.

# Existing VPC and subnets
data "aws_vpc" "main_vpc" {
  tags = {
    Name = var.vpc_name
  }
}
data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main_vpc.id]
  }
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}
data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main_vpc.id]
  }
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

# DB Subnet Groups
resource "aws_db_subnet_group" "db_subnets" {
  name       = "report-a-defect-db-subnet"
  subnet_ids = data.aws_subnets.private_subnets.ids

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_elasticache_subnet_group" "redis_subnets" {
  name       = "report-a-defect-redis-subnet"
  subnet_ids = data.aws_subnets.private_subnets.ids
}

# DB Security Group
resource "aws_security_group" "db_security_group" {
  vpc_id      = data.aws_vpc.main_vpc.id
  name_prefix = "allow_${local.database_name}_db_traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all outbound traffic"
  }
}
resource "aws_security_group_rule" "allow_ecs_to_rds" {
  type                     = "ingress"
  from_port                = local.database_port
  to_port                  = local.database_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_security_group.id
  source_security_group_id = aws_security_group.ecs_task_sg.id
  description              = "Allow ECS tasks to talk to Postgres"
}
resource "aws_security_group_rule" "allow_bastion_to_rds" {
  type                     = "ingress"
  from_port                = local.database_port
  to_port                  = local.database_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_security_group.id
  source_security_group_id = var.bastion_sg_id
  description              = "Allow Bastion access to RDS (Postgres)"
}
resource "aws_security_group_rule" "allow_ecs_to_redis" {
  type                     = "ingress"
  from_port                = local.redis_port
  to_port                  = local.redis_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_security_group.id
  source_security_group_id = aws_security_group.ecs_task_sg.id
  description              = "Allow ECS tasks to talk to Redis"
}
resource "aws_security_group_rule" "allow_bastion_to_redis" {
  type                     = "ingress"
  from_port                = local.redis_port
  to_port                  = local.redis_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_security_group.id
  source_security_group_id = var.bastion_sg_id
  description              = "Allow Bastion access to Redis"
}

# ECS Security Group
resource "aws_security_group" "ecs_task_sg" {
  name        = "report-a-defect-ecs-sg"
  description = "Security group for report a defect ECS tasks"
  vpc_id      = data.aws_vpc.main_vpc.id
}
resource "aws_security_group_rule" "allow_outbound_to_secrets_manager" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs_task_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow outbound traffic to Secrets Manager"
}
resource "aws_security_group_rule" "allow_inbound_from_db" {
  type                     = "ingress"
  from_port                = local.database_port
  to_port                  = local.database_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_task_sg.id
  source_security_group_id = aws_security_group.db_security_group.id
  description              = "allow inbound traffic from the DB security group"
}
resource "aws_security_group_rule" "allow_inbound_from_lb" {
  type                     = "ingress"
  from_port                = local.app_port
  to_port                  = local.app_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_task_sg.id
  source_security_group_id = aws_security_group.lb_sg.id
  description              = "allow inbound traffic from the load balancer"
}
resource "aws_security_group_rule" "allow_bastion_to_ecs" {
  type                     = "ingress"
  from_port                = local.app_port
  to_port                  = local.app_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_task_sg.id
  source_security_group_id = var.bastion_sg_id
  description              = "Allow Bastion access to ECS tasks"
}

# LB security group
resource "aws_security_group" "lb_sg" {
  name        = "report-a-defect-lb-sg"
  description = "Security group for report a defect NLB"
  vpc_id      = data.aws_vpc.main_vpc.id

  ingress {
    description = "allow all inbound traffic from the VPC"
    from_port   = local.app_port
    to_port     = local.app_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main_vpc.cidr_block]
  }
  egress {
    description     = "allow outbound traffic to the ECS tasks"
    from_port       = local.app_port
    to_port         = local.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_task_sg.id]
  }
}