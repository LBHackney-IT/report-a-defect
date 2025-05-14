# Defines IAM roles and policies needed by ECS, EventBridge, and other resources.
# Ensures proper permissions for services to interact securely.

data "aws_kms_alias" "secretsmanager" {
  name = "alias/aws/secretsmanager"
}

# Execution Role
resource "aws_iam_role" "ecs_execution_role" {
  name = "report-a-defect-ecs-execution-role"

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
  name        = "report-a-defect-ecs-execution-policy"
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
  name = "report-a-defect-ecs-task-role"

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
  name        = "report-a-defect-ecs-task-policy"
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

# EventBridge Role
resource "aws_iam_role" "eventbridge_invoke_ecs" {
  name = "eventbridge-invoke-ecs-role-report-a-defect"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy" "eventbridge_ecs_policy" {
  name = "eventbridge-invoke-ecs-policy-report-a-defect"
  role = aws_iam_role.eventbridge_invoke_ecs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecs:RunTask"]
        Resource = aws_ecs_task_definition.worker_task.arn
      },
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = aws_iam_role.ecs_task_role.arn
      }
    ]
  })
}