provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      Application = "Report a Defect"
      TeamEmail   = "mmh-project-team@hackney.gov.uk" # Note: To change once HPT email is confirmed
      Environment = "development"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

terraform {
  backend "s3" {
    bucket  = "terraform-state-housing-development"
    encrypt = true
    region  = "eu-west-2"
    key     = "services/lbh-report-a-defect/state"
  }
}

variable "enable_ecs_service" {
  type    = bool
  default = true
}

variable "image_tag" {
  type    = string
  default = "latest"
}

locals {
  environment_name         = "development"
  lang                     = "en_US.UTF-8"
  new_relic_log            = "stdout"
  rack_env                 = "staging"
  rails_env                = "staging"
  rails_log_to_stdout      = "enabled"
  rails_serve_static_files = "enabled"
  ssm_params = [
    "auth0_client_id",
    "auth0_client_secret",
    "auth0_domain",
    "http_pass",
    "http_user",
    "nbt_group_email",
    "new_relic_license_key",
    "notify_daily_due_soon_template",
    "notify_daily_escalation_template",
    "notify_defect_accepted_by_contractor_template",
    "notify_defect_completed_template",
    "notify_defect_sent_to_contractor_template",
    "notify_forward_defect_template",
    "notify_key",
    "papertrail_api_token",
    "redis_url",
    "secret_key_base",
    "sentry_dsn",
    "sms_blacklist"
  ]
}

# Dynamically pull all SSM parameters
data "aws_ssm_parameter" "params" {
  for_each = toset(local.ssm_params)
  name     = "/report-a-defect/${local.environment_name}/${each.value}"
}

data "aws_vpc" "development_vpc" {
  tags = {
    Name = "housing-dev"
  }
}
data "aws_subnets" "development_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.development_vpc.id]
  }
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_subnets" "development_public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.development_vpc.id]
  }
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

# Database Module (postgres)
module "aws-rds-lbh" {
  source               = "github.com/LBHackney-IT/aws-rds-lbh?ref=5583941f81fe14c3f365b19de22ec256a3b1ceae"
  application          = "report-a-defect"
  db_allocated_storage = 10
  db_engine_version    = "15.8"
  db_family            = "postgres15"
  db_identifier        = "report-a-defect-db-${local.environment_name}"
  db_instance_class    = "db.t3.micro"
  db_name              = "reportadefect"
  db_subnet_group_name = "report-a-defect-db-${local.environment_name}"
  subnet_ids           = data.aws_subnets.development_private_subnets.ids
  db_username          = "report_a_defect_admin"
  environment          = local.environment_name
  kms_key_arn          = "arn:aws:kms:eu-west-2:${data.aws_caller_identity.current.account_id}:key/3cdafea1-f12f-4a3b-84c1-3a284d5ebaf4"
  vpc_id               = data.aws_vpc.development_vpc.id
}

# ECS Module

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "report_a_defect" {
  name = "ecs-task-report-a-defect-${local.environment_name}"

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

  ecs_service_config = var.enable_ecs_service ? {
    "report-a-defect" = {
      family             = "report-a-defect"
      memory             = 1024
      cpu                = 512
      execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"
      task_role_arn      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"
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
          environment = [
            { name = "AUTH0_CLIENT_ID", value = data.aws_ssm_parameter.params["auth0_client_id"].value },
            { name = "AUTH0_CLIENT_SECRET", value = data.aws_ssm_parameter.params["auth0_client_secret"].value },
            { name = "AUTH0_DOMAIN", value = data.aws_ssm_parameter.params["auth0_domain"].value },
            { name = "DATABASE_URL", value = "TODO" },
            { name = "HTTP_PASS", value = data.aws_ssm_parameter.params["http_pass"].value },
            { name = "HTTP_USER", value = data.aws_ssm_parameter.params["http_user"].value },
            { name = "LANG", value = local.lang },
            { name = "NBT_GROUP_EMAIL", value = data.aws_ssm_parameter.params["nbt_group_email"].value },
            { name = "NEW_RELIC_LICENSE_KEY", value = data.aws_ssm_parameter.params["new_relic_license_key"].value },
            { name = "NEW_RELIC_LOG", value = local.new_relic_log },
            { name = "NOTIFY_DAILY_DUE_SOON_TEMPLATE", value = data.aws_ssm_parameter.params["notify_daily_due_soon_template"].value },
            { name = "NOTIFY_DAILY_ESCALATION_TEMPLATE", value = data.aws_ssm_parameter.params["notify_daily_escalation_template"].value },
            { name = "NOTIFY_DEFECT_ACCEPTED_BY_CONTRACTOR_TEMPLATE", value = data.aws_ssm_parameter.params["notify_defect_accepted_by_contractor_template"].value },
            { name = "NOTIFY_DEFECT_COMPLETED_TEMPLATE", value = data.aws_ssm_parameter.params["notify_defect_completed_template"].value },
            { name = "NOTIFY_DEFECT_SENT_TO_CONTRACTOR_TEMPLATE", value = data.aws_ssm_parameter.params["notify_defect_sent_to_contractor_template"].value },
            { name = "NOTIFY_FORWARD_DEFECT_TEMPLATE", value = data.aws_ssm_parameter.params["notify_forward_defect_template"].value },
            { name = "NOTIFY_KEY", value = data.aws_ssm_parameter.params["notify_key"].value },
            { name = "PAPERTRAIL_API_TOKEN", value = data.aws_ssm_parameter.params["papertrail_api_token"].value },
            { name = "RACK_ENV", value = local.rack_env },
            { name = "RAILS_ENV", value = local.rails_env },
            { name = "RAILS_LOG_TO_STDOUT", value = local.rails_log_to_stdout },
            { name = "RAILS_SERVE_STATIC_FILES", value = local.rails_serve_static_files },
            { name = "REDIS_URL", value = data.aws_ssm_parameter.params["redis_url"].value },
            { name = "SECRET_KEY_BASE", value = data.aws_ssm_parameter.params["secret_key_base"].value },
            { name = "SENTRY_DSN", value = data.aws_ssm_parameter.params["sentry_dsn"].value },
            { name = "SMS_BLACKLIST", value = data.aws_ssm_parameter.params["sms_blacklist"].value }
          ]
        }
      ])
    }
  } : {}
}

output "ecr_repository_url" {
  value = module.aws-ecs-lbh.ecr_repository_url
}
