# S3 Bucket
resource "aws_s3_bucket" "image_bucket" {
  bucket = "report-a-defect-images-${var.environment_name}"
}
resource "aws_s3_bucket_policy" "image_bucket_policy" {
  bucket = aws_s3_bucket.image_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = [
        "s3:PutObject",
        "s3:GetObject",
      ],
      Resource = "${aws_s3_bucket.image_bucket.arn}/*",
      Condition = {
        Bool = {
          "aws:SecureTransport" = "true"
        }
      }
    }]
  })
}
resource "aws_s3_bucket_cors_configuration" "image_bucket_cors" {
  bucket = aws_s3_bucket.image_bucket.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE"]
    allowed_origins = [aws_lb.nlb.dns_name]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
resource "aws_ssm_parameter" "bucket_name" {
  name        = "/report-a-defect/${var.environment_name}/aws_bucket"
  type        = "String"
  value       = aws_s3_bucket.image_bucket.bucket
  description = "S3 bucket name for report-a-defect images"
  overwrite   = true
}

# Roles

data "aws_kms_alias" "secretsmanager" {
  name = "alias/aws/secretsmanager"
}

# Execution Role
resource "aws_iam_role" "ecs_execution_role" {
  name = "report-a-defect-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement : [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_policy" "ecs_execution_policy" {
  name        = "report-a-defect-execution-policy"
  description = "Scoped permissions for ECS task execution role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Sid : "ECRAccess",
        Effect : "Allow",
        Action : [
          "ecr:GetAuthorizationToken"
        ],
        Resource : "*"
      },
      {
        Sid : "ECRRepoAccess",
        Effect : "Allow",
        Action : [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Resource : "${aws_ecr_repository.app_repository.arn}"
      },
      {
        Sid : "CloudWatchLogsAccess",
        Effect : "Allow",
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource : [
          aws_cloudwatch_log_group.report_a_defect.arn,
          "${aws_cloudwatch_log_group.report_a_defect.arn}:log-stream:*",
          aws_cloudwatch_log_group.report_a_defect_worker.arn,
          "${aws_cloudwatch_log_group.report_a_defect_worker.arn}:log-stream:*"
        ]
      },
      {
        Sid : "SecretsAccess",
        Effect : "Allow",
        Action : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource : [
          for secret in data.aws_secretsmanager_secret.secrets : secret.arn
        ]
      },
      {
        Sid : "KMSAccess",
        Effect : "Allow",
        Action : [
          "kms:Decrypt"
        ],
        Resource : data.aws_kms_alias.secretsmanager.target_key_arn
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_execution_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_policy.arn
}

# Task Role
resource "aws_iam_role" "ecs_task_role" {
  name = "report-a-defect-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement : [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_policy" "ecs_task_policy" {
  name        = "report-a-defect-task-policy"
  description = "Permissions for ECS task role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ],
        Resource : [
          aws_s3_bucket.image_bucket.arn,
          "${aws_s3_bucket.image_bucket.arn}/*"
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_task_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

# ECR
resource "aws_ecr_repository" "app_repository" {
  name                 = "report-a-defect-ecr-dev"
  image_tag_mutability = "MUTABLE"
}
resource "aws_ecr_repository_policy" "app_policy" {
  repository = aws_ecr_repository.app_repository.name
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

# ECS

# Get secret ARNs from AWS Secrets Manager
data "aws_secretsmanager_secret" "secrets" {
  depends_on = [aws_secretsmanager_secret_version.database_url_version]
  for_each   = toset(var.secret_names)
  name       = "report-a-defect-${each.value}"
}
# Pull all environment variables from SSM
data "aws_ssm_parameter" "params" {
  depends_on = [
    aws_ssm_parameter.bucket_name,
    aws_ssm_parameter.app_domain_name,
    aws_ssm_parameter.redis_url
  ]
  for_each = toset(var.ssm_params)
  name     = "/report-a-defect/${var.environment_name}/${each.value}"
}

# Logging
resource "aws_cloudwatch_log_group" "report_a_defect" {
  name              = "ecs-task-report-a-defect-app-${var.environment_name}"
  retention_in_days = 60
}
resource "aws_cloudwatch_log_group" "report_a_defect_worker" {
  name              = "ecs-task-report-a-defect-worker-${var.environment_name}"
  retention_in_days = 60
}

# Service + Task Definition
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
    container_port   = var.app_port
  }
}
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
    {
      name      = "report-a-defect-app-container"
      image     = "${aws_ecr_repository.app_repository.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = var.app_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.report_a_defect.name}"
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = "report-a-defect-${var.environment_name}-logs"
        }
      }
      # Dynamically set secrets and environment variables from SSM and Secrets Manager
      secrets = [
        for secret_key, secret_value in data.aws_secretsmanager_secret.secrets :
        {
          name      = upper(replace(secret_key, "-", "_")) # kebab to screaming_snake
          valueFrom = secret_value.arn
        }
      ]

      environment = [
        for param_key, param_value in data.aws_ssm_parameter.params :
        {
          name  = upper(param_key) # snake to screaming_snake
          value = param_value.value
        }
      ]
    },
    {
      name      = "report-a-defect-worker-container"
      image     = "${aws_ecr_repository.app_repository.repository_url}:latest"
      essential = true
      command   = ["rake", "notify:escalated_defects", "rake", "notify:due_soon_and_overdue_defects"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.report_a_defect_worker.name}"
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = "report-a-defect-worker-${var.environment_name}-logs"
        }
      }
      # Dynamically set secrets and environment variables from SSM and Secrets Manager
      secrets = [
        for secret_key, secret_value in data.aws_secretsmanager_secret.secrets :
        {
          name      = upper(replace(secret_key, "-", "_")) # kebab to screaming_snake
          valueFrom = secret_value.arn
        }
      ]

      environment = [
        for param_key, param_value in data.aws_ssm_parameter.params :
        {
          name  = upper(param_key) # snake to screaming_snake
          value = param_value.value
        }
      ]
    }
  ])
}
resource "aws_ecs_cluster" "app_cluster" {
  name = "report-a-defect-cluster"
}

# Scheduled Tasks
resource "aws_scheduler_schedule" "cron" {
  name        = "report-a-defect-scheduled-tasks"
  description = "Scheduled tasks for report-a-defect"
  group_name  = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(30 17 * * ? *)" # Every day at 17:30 UTC

  target {
    arn      = aws_ecs_cluster.app_cluster.arn
    role_arn = aws_iam_role.scheduler.arn

    ecs_parameters {
      # trimming the revision suffix here so that schedule always uses latest revision
      task_definition_arn = trimsuffix(aws_ecs_task_definition.app_task.arn, ":${aws_ecs_task_definition.app_task.revision}")
      launch_type         = "FARGATE"

      network_configuration {
        assign_public_ip = false
        security_groups  = [aws_security_group.ecs_task_sg.id]
        subnets          = data.aws_subnets.public_subnets.ids
      }
    }

    retry_policy {
      maximum_event_age_in_seconds = 300
      maximum_retry_attempts       = 10
    }
  }
}

resource "aws_iam_role" "scheduler" {
  name = "report-a-defect-cron-scheduler-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["scheduler.amazonaws.com"]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "scheduler" {
  policy_arn = aws_iam_policy.scheduler.arn
  role       = aws_iam_role.scheduler.name
}
resource "aws_iam_policy" "scheduler" {
  name = "cron-scheduler-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # allow scheduler to execute the task
        Effect = "Allow",
        Action = [
          "ecs:RunTask"
        ]
        # trim :<revision> from arn, to point at the whole task definition and not just one revision
        Resource = [trimsuffix(aws_ecs_task_definition.app_task.arn, ":${aws_ecs_task_definition.app_task.revision}")]
      },
      { # allow scheduler to set the IAM roles of your task
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.ecs_execution_role.arn,
          aws_iam_role.ecs_task_role.arn,
        ]
      },
    ]
  })
}