locals {
  # Dynamically pull all environment variables from SSM
  ssm_params = [
    "auth0_client_id",
    "auth0_domain",
    "aws_bucket",
    "aws_region",
    "http_pass",
    "http_user",
    "lang",
    "nbt_group_email",
    "new_relic_log",
    "notify_daily_due_soon_template",
    "notify_daily_escalation_template",
    "notify_defect_accepted_by_contractor_template",
    "notify_defect_completed_template",
    "notify_defect_sent_to_contractor_template",
    "notify_forward_defect_template",
    "rack_env",
    "rails_env",
    "rails_log_to_stdout",
    "rails_serve_static_files",
    "redis_url",
    "sentry_dsn",
    "sms_blacklist"
  ]
}
data "aws_ssm_parameter" "params" {
  for_each = toset(local.ssm_params)
  name     = "/report-a-defect/${local.environment_name}/${each.value}"
}

# Get secret arns from AWS Secrets Manager
locals {
  secret_names = [
    "database-url",
    "aws-access-key-id",
    "aws-secret-access-key",
    "auth0-client-secret",
    "new-relic-license-key",
    "notify-key",
    "papertrail-api-token",
    "secret-key-base"
  ]
}

data "aws_secretsmanager_secret" "secrets" {
  for_each = toset(local.secret_names)
  name     = "report-a-defect-${each.value}"
}

# CloudWatch Log Group for ECS Task
resource "aws_cloudwatch_log_group" "report_a_defect" {
  name              = "ecs-task-report-a-defect-${local.environment_name}"
  retention_in_days = 60
}

module "aws-ecs-lbh" {
  source                = "github.com/LBHackney-IT/aws-ecs-lbh?ref=27607834b4821b01ba0f0fade8e292181fe9658e"
  application           = "report-a-defect"
  environment           = local.environment_name
  vpc_id                = data.aws_vpc.development_vpc.id
  task_subnets          = data.aws_subnets.development_private_subnets.ids
  create_alb            = true
  alb_subnets           = data.aws_subnets.development_public_subnets.ids
  create_cluster        = true
  create_ecr_repository = true
  listener_port         = 80
  listener_protocol     = "HTTP"
  depends_on            = [aws_cloudwatch_log_group.report_a_defect]

  alb_access_logs_configuration = {
    access_log_prefix = "ecs-task-report-a-defect-${local.environment_name}"
    retention_period  = 7
  }

  ecs_service_config = {
    "report-a-defect" = {
      family             = "report-a-defect"
      memory             = 1024
      cpu                = 512
      execution_role_arn = aws_iam_role.ecs_execution_role.arn
      task_role_arn      = aws_iam_role.ecs_task_role.arn
      launch_type        = "FARGATE"
      container_definitions = jsonencode([
        {
          name         = "report-a-defect-container"
          image        = "${module.aws-ecs-lbh.ecr_repository_url}:${var.image_tag}"
          memory       = 1024
          cpu          = 512
          essential    = true
          portMappings = [{ containerPort = 3001 }]
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = "${aws_cloudwatch_log_group.report_a_defect.name}"
              awslogs-region        = "eu-west-2"
              awslogs-stream-prefix = "report-a-defect-${local.environment_name}-logs"
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
  }
}