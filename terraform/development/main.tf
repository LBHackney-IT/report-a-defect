provider "aws" {
  region  = "eu-west-2"
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
    application_name = "lbh income api"
    parameter_store = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter"
}

# SSM Parameters - Systems Manager/Parameter Store

# Terraform State Management
terraform {
  backend "s3" {
    bucket  = "terraform-state-housing-development"
    encrypt = true
    region  = "eu-west-2"
    key     = "services/lbh-income-api/state"
  }
}

resource "aws_ecr_repository" "income-api" {
    name                 = "hackney/apps/income-api"
    image_tag_mutability = "MUTABLE"
}

#Elastic Container Registry (ECR) setup
resource "aws_ecr_repository_policy" "income-api-policy" {
    repository = aws_ecr_repository.income-api.name
    policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "logs:CreateLogGroup"
        ]
      }
    ]
  }
  EOF
}

# Elastic Container Service (ECS) setup
resource "aws_ecs_cluster" "manage-arrears-ecs-cluster" {
  name = "ecs-cluster-for-manage-arrears"
}

resource "aws_ecs_service" "income-api-ecs-service" {
    name            = "income-api-ecs-service"
    cluster         = aws_ecs_cluster.manage-arrears-ecs-cluster.id
    task_definition = aws_ecs_task_definition.income-api-ecs-task-definition.arn
    launch_type     = "FARGATE"

    network_configuration {
        subnets          = ["subnet-0140d06fb84fdb547", "subnet-05ce390ba88c42bfd"]
        security_groups = ["sg-00d2e14f38245dd0b"]
        assign_public_ip = false
    }
    desired_count = 1
    load_balancer {
      target_group_arn = aws_lb_target_group.lb_tg.arn
      container_name   = "income-api-container"
      container_port   = 3000
  }
}

resource "aws_ecs_task_definition" "income-api-ecs-task-definition" {
    family                   = "ecs-task-definition-income-api"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    memory                   = "4096"
    cpu                      = "1024"
    execution_role_arn       = "arn:aws:iam::364864573329:role/ecsTaskExecutionRole"
    task_role_arn            = "arn:aws:iam::364864573329:role/ecsTaskExecutionRole"
    container_definitions    = <<DEFINITION
[
  {
    "name": "income-api-container",
    "image": "364864573329.dkr.ecr.eu-west-2.amazonaws.com/hackney/apps/income-api:${var.sha1}",
    "memory": 2048,
    "cpu": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 3000
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "ecs-task-definition-income-api",
            "awslogs-region": "eu-west-2",
            "awslogs-stream-prefix": "income-api-logs"
        }
    },
    "environment": [
    ....
    ]
  }
]
DEFINITION
}

# MySQL Database Setup
resource "aws_db_subnet_group" "db_subnets" {
  name       = "housing-finance-db-subnet-development"
  subnet_ids = ["subnet-05ce390ba88c42bfd","subnet-0140d06fb84fdb547"]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "housing-mysql-db" {
  identifier                  = "housing-finance-db-development"
  engine                      = "mysql"
  engine_version              = "8.0.35"
  instance_class              = "db.t3.micro" //this should be a more production appropriate instance in production
  allocated_storage           = 10
  storage_type                = "gp2" //ssd
  port                        = 3306
  backup_window               = "00:01-00:31"
  username                    = data.aws_ssm_parameter.housing_finance_mysql_username.value
  password                    = data.aws_ssm_parameter.housing_finance_mysql_password.value
  vpc_security_group_ids      = ["sg-00d2e14f38245dd0b"]
  db_subnet_group_name        = aws_db_subnet_group.db_subnets.name
  name                        = data.aws_ssm_parameter.housing_finance_mysql_database.value
  monitoring_interval         = 0 //this is for enhanced Monitoring there will already be some basic monitoring available
  backup_retention_period     = 30
  storage_encrypted           = false  //this should be true for production
  deletion_protection         = false
  multi_az                    = false //this should be true for production
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false

  apply_immediately   = false
  skip_final_snapshot = true
  publicly_accessible = false

  tags = {
    Name              = "housing-finance-db-development"
    Environment       = "development"
    terraform-managed = true
    project_name      = "Housing Finance"
  }
}

# Network Load Balancer (NLB) setup
resource "aws_lb" "lb" {
  name               = "lb-income-api"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["subnet-0140d06fb84fdb547", "subnet-05ce390ba88c42bfd"]// Get this from AWS (data)
  enable_deletion_protection = false
  tags = {
    Environment = "development"
  }
}

resource "aws_lb_target_group" "lb_tg" {
  depends_on  = [
    aws_lb.lb
  ]
  name_prefix = "ma-tg-"
  port        = 3000
  protocol    = "TCP"
  vpc_id      = "vpc-0d15f152935c8716f" // Get this from AWS (data)
  target_type = "ip"
  stickiness {
    enabled = false
    type = "lb_cookie"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Redirect all traffic from the NLB to the target group
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.id
  port              = 3000
  protocol    = "TCP"
  default_action {
    target_group_arn = aws_lb_target_group.lb_tg.id
    type             = "forward"
  }
}

# API Gateway setup
# VPC Link
resource "aws_api_gateway_vpc_link" "this" {
  name = "vpc-link-income-api"
  target_arns = [aws_lb.lb.arn]
}
# API Gateway, Private Integration with VPC Link
# and deployment of a single resource that will take ANY
# HTTP method and proxy the request to the NLB
resource "aws_api_gateway_rest_api" "main" {
  name = "development-income-api"
}
resource "aws_api_gateway_resource" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{proxy+}"
}
resource "aws_api_gateway_method" "main" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.main.id
  http_method   = "ANY"
  authorization = "NONE"
  api_key_required = true
  request_parameters = {
    "method.request.path.proxy" = true
  }
}
resource "aws_api_gateway_integration" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.lb.dns_name}:3000/{proxy}"
  integration_http_method = "ANY"
  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.this.id
}
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name = "development"
  depends_on = [aws_api_gateway_integration.main]
  variables = {
    # just to trigger redeploy on resource changes
    resources = join(", ", [aws_api_gateway_resource.main.id])
    # note: redeployment might be required with other gateway changes.
    # when necessary run terraform taint <this resource's address>
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_usage_plan" "main" {
  name = "income_api_development_usage_plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = aws_api_gateway_deployment.main.stage_name
  }
}

resource "aws_api_gateway_api_key" "main" {
  name = "income_api_development_key"
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.main.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main.id
}