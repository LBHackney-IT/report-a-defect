# Configures ECS resources, including clusters, task definitions, and services.
# This is where app-related compute resources are defined, including the setup for ECS containers.

# ECR
resource "aws_ecr_repository" "app_repository" {
  name                 = "report-a-defect-${var.environment_name}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}
resource "aws_ecr_repository_policy" "app_policy" {
  repository = aws_ecr_repository.app_repository.name
  policy = jsonencode(
    {
      Version = "2008-10-17"
      Statement = [
        {
          Sid       = "ECRPublicAccess",
          Effect    = "Allow",
          Principal = "*",
          Action = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:BatchGetImage",
            "ecr:CompleteLayerUpload",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetLifecyclePolicy",
            "ecr:InitiateLayerUpload",
            "ecr:PutImage",
            "ecr:UploadLayerPart"
          ]
        }
      ]
    }
  )
}

# Cluster & Two Services (App and Worker)
# The app service is the main web app, while the worker service handles background jobs (sidekiq).
resource "aws_ecs_cluster" "app_cluster" {
  name = "report-a-defect-cluster"
}
resource "aws_ecs_service" "app_service" {
  name            = "report-a-defect-app-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.public_subnets.ids
    security_groups  = [aws_security_group.ecs_task_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    container_name   = "report-a-defect-app"
    container_port   = local.app_port
  }

  tags = {
    WeekendShutdown    = "true"
    OutOfHoursShutdown = "true"
  }
}
resource "aws_ecs_service" "worker_service" {
  name            = "report-a-defect-worker-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.worker_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.public_subnets.ids
    security_groups  = [aws_security_group.ecs_task_sg.id]
    assign_public_ip = false
  }

  tags = {
    WeekendShutdown    = "true"
    OutOfHoursShutdown = "true"
  }
}

# Task Definitions

# Environment Variables
data "aws_secretsmanager_secret" "secrets" {
  depends_on = [aws_secretsmanager_secret_version.database_url_version]
  for_each   = toset(local.secret_names)
  name       = "report-a-defect-${each.value}"
}
data "aws_ssm_parameter" "params" {
  depends_on = [
    aws_ssm_parameter.app_domain_name,
    aws_ssm_parameter.redis_url
  ]
  for_each = toset(local.ssm_params)
  name     = "/report-a-defect/${var.environment_name}/${each.value}"
}

# App Task Definition
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/ecs/${var.environment_name}/report-a-defect-app-logs"
  retention_in_days = 60
}
resource "aws_ecs_task_definition" "app_task" {
  depends_on               = [aws_cloudwatch_log_group.app_logs]
  family                   = "report-a-defect-app"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  container_definitions = jsonencode([
    merge(
      local.container_definition_base,
      {
        name         = "report-a-defect-app"
        portMappings = [{ containerPort = local.app_port, protocol = "tcp" }]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.app_logs.name
            awslogs-region        = "eu-west-2"
            awslogs-stream-prefix = "ecs"
          }
        }
      }
    )
  ])
}

# Worker Task Definition
resource "aws_cloudwatch_log_group" "worker_logs" {
  name              = "/ecs/${var.environment_name}/report-a-defect-worker-logs"
  retention_in_days = 60
}
resource "aws_ecs_task_definition" "worker_task" {
  depends_on               = [aws_cloudwatch_log_group.worker_logs]
  family                   = "report-a-defect-worker"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  container_definitions = jsonencode([
    merge(
      local.container_definition_base,
      {
        name    = "report-a-defect-worker",
        command = ["/bin/sh", "-c", "bundle exec sidekiq -C config/sidekiq.yml"],
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.worker_logs.name
            awslogs-region        = "eu-west-2"
            awslogs-stream-prefix = "ecs"
          }
        }
      }
    )
  ])
}