# Get default KMS key
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
        Resource : "arn:aws:ecr:eu-west-2:${data.aws_caller_identity.current.account_id}:repository/report-a-defect-ecr-development"
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
