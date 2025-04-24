# Get secret ARNs from AWS Secrets Manager
data "aws_secretsmanager_secret" "secrets" {
  for_each = toset(var.secret_names)
  name     = "report-a-defect-${each.value}"
}
# Pull all environment variables from SSM
data "aws_ssm_parameter" "params" {
  for_each = toset(var.ssm_params)
  name     = "/report-a-defect/${var.environment_name}/${each.value}"
}

# Role
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
          "${aws_cloudwatch_log_group.report_a_defect.arn}:log-stream:*"
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
        ],
        Resource : "*" # TODO: Update to specific S3 bucket ARN when migrated
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
resource "aws_cloudwatch_log_group" "report_a_defect" {
  name              = "ecs-task-report-a-defect-${var.environment_name}"
  retention_in_days = 60
}
resource "aws_ecs_service" "app_service" {
  name            = "report-a-defect-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.development_public_subnets.ids
    security_groups  = ["sg-00d2e14f38245dd0b"]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    container_name   = "report-a-defect-app-container"
    container_port   = var.app_port
  }
}
resource "aws_ecs_task_definition" "app_task" {
  depends_on               = [aws_cloudwatch_log_group.report_a_defect]
  family                   = "ecs-task-definition-report-a-defect"
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
          hostPort      = var.app_port
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
      secrets = [{
        name      = "DATABASE_URL"
        valueFrom = data.aws_secretsmanager_secret.secrets["database-url"].arn
        },
        {
          name      = "AWS_ACCESS_KEY_ID"
          valueFrom = data.aws_secretsmanager_secret.secrets["aws-access-key-id"].arn
        },
        {
          name      = "AWS_SECRET_ACCESS_KEY"
          valueFrom = data.aws_secretsmanager_secret.secrets["aws-secret-access-key"].arn
        },
        {
          name      = "AUTH0_CLIENT_SECRET"
          valueFrom = data.aws_secretsmanager_secret.secrets["auth0-client-secret"].arn
        },
        {
          name      = "NEW_RELIC_LICENSE_KEY"
          valueFrom = data.aws_secretsmanager_secret.secrets["new-relic-license-key"].arn
        },
        {
          name      = "NOTIFY_KEY"
          valueFrom = data.aws_secretsmanager_secret.secrets["notify-key"].arn
        },
        {
          name      = "PAPERTRAIL_API_TOKEN"
          valueFrom = data.aws_secretsmanager_secret.secrets["papertrail-api-token"].arn
        },
        {
          name      = "SECRET_KEY_BASE"
          valueFrom = data.aws_secretsmanager_secret.secrets["secret-key-base"].arn
      }]
      environment = [
        { name = "AWS_REGION", value = data.aws_ssm_parameter.params["aws_region"].value },
        { name = "AWS_BUCKET", value = data.aws_ssm_parameter.params["aws_bucket"].value },
        { name = "AUTH0_CLIENT_ID", value = data.aws_ssm_parameter.params["auth0_client_id"].value },
        { name = "AUTH0_DOMAIN", value = data.aws_ssm_parameter.params["auth0_domain"].value },
        { name = "HTTP_PASS", value = data.aws_ssm_parameter.params["http_pass"].value },
        { name = "HTTP_USER", value = data.aws_ssm_parameter.params["http_user"].value },
        { name = "LANG", value = data.aws_ssm_parameter.params["lang"].value },
        { name = "NBT_GROUP_EMAIL", value = data.aws_ssm_parameter.params["nbt_group_email"].value },
        { name = "NEW_RELIC_LOG", value = data.aws_ssm_parameter.params["new_relic_log"].value },
        { name = "NOTIFY_DAILY_DUE_SOON_TEMPLATE", value = data.aws_ssm_parameter.params["notify_daily_due_soon_template"].value },
        { name = "NOTIFY_DAILY_ESCALATION_TEMPLATE", value = data.aws_ssm_parameter.params["notify_daily_escalation_template"].value },
        { name = "NOTIFY_DEFECT_ACCEPTED_BY_CONTRACTOR_TEMPLATE", value = data.aws_ssm_parameter.params["notify_defect_accepted_by_contractor_template"].value },
        { name = "NOTIFY_DEFECT_COMPLETED_TEMPLATE", value = data.aws_ssm_parameter.params["notify_defect_completed_template"].value },
        { name = "NOTIFY_DEFECT_SENT_TO_CONTRACTOR_TEMPLATE", value = data.aws_ssm_parameter.params["notify_defect_sent_to_contractor_template"].value },
        { name = "NOTIFY_FORWARD_DEFECT_TEMPLATE", value = data.aws_ssm_parameter.params["notify_forward_defect_template"].value },
        { name = "RACK_ENV", value = data.aws_ssm_parameter.params["rack_env"].value },
        { name = "RAILS_ENV", value = data.aws_ssm_parameter.params["rails_env"].value },
        { name = "RAILS_LOG_TO_STDOUT", value = data.aws_ssm_parameter.params["rails_log_to_stdout"].value },
        { name = "RAILS_SERVE_STATIC_FILES", value = data.aws_ssm_parameter.params["rails_serve_static_files"].value },
        { name = "REDIS_URL", value = data.aws_ssm_parameter.params["redis_url"].value },
        { name = "SENTRY_DSN", value = data.aws_ssm_parameter.params["sentry_dsn"].value },
        { name = "SMS_BLACKLIST", value = data.aws_ssm_parameter.params["sms_blacklist"].value }
      ]
    }
  ])
}
resource "aws_ecs_cluster" "app_cluster" {
  name = "report-a-defect-cluster"
}