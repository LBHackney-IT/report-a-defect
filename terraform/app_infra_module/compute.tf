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

# Cluster & Service
resource "aws_ecs_cluster" "app_cluster" {
  name = "report-a-defect-cluster"
}
resource "aws_ecs_service" "app_service" {
  name            = "report-a-defect-service"
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
    container_name   = "report-a-defect-app-container"
    container_port   = local.app_port
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
    aws_ssm_parameter.bucket_name,
    aws_ssm_parameter.app_domain_name,
    aws_ssm_parameter.redis_url
  ]
  for_each = toset(local.ssm_params)
  name     = "/report-a-defect/${var.environment_name}/${each.value}"
}

# Logging
resource "aws_cloudwatch_log_group" "report_a_defect" {
  name              = "/ecs/report-a-defect-app-task-${var.environment_name}"
  retention_in_days = 60
}
resource "aws_cloudwatch_log_group" "report_a_defect_worker" {
  name              = "/ecs/report-a-defect-worker-task-${var.environment_name}"
  retention_in_days = 60
}

# Tasks
resource "aws_ecs_task_definition" "app_task" {
  depends_on               = [aws_cloudwatch_log_group.report_a_defect, aws_cloudwatch_log_group.report_a_defect_worker]
  family                   = "report-a-defect-app-container"
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
        name         = "report-a-defect-app-container"
        portMappings = [{ containerPort = local.app_port, protocol = "tcp" }]
      }
    )
  ])
}
resource "aws_ecs_task_definition" "worker_task" {
  family                   = "report-a-defect-worker-task"
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
        name    = "report-a-defect-worker-container",
        command = ["scheduled_tasks.sh"]
      }
    )
  ])
}