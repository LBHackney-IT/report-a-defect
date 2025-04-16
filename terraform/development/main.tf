provider "aws" {
  region = "eu-west-2"
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

locals {
  lang                     = "en_US.UTF-8"
  new_relic_log            = "stdout"
  rack_env                 = "staging"
  rails_env                = "staging"
  rails_log_to_stdout      = "enabled"
  rails_serve_static_files = "enabled"
  ssm_params = [
    "postgres/username",
    "postgres/password",
    "postgres/database",
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
  name     = "/report-a-defect/development/${each.value}"
}

# RDS Module
module "aws-rds-lbh" {
  source = "github.com/LBHackney-IT/aws-rds-lbh?ref=5583941f81fe14c3f365b19de22ec256a3b1ceae"
  application = "report-a-defect"
  db_allocated_storage = 10
  db_engine_version = "15.8"
  db_family = "postgres15"
  db_identifier = "report-a-defect-db-development"
  db_instance_class = "db.t3.micro"
  db_name = data.aws_ssm_parameter.params["postgres/database"].value
  db_subnet_group_name = "report-a-defect-db-development"
  db_username = data.aws_ssm_parameter.params["postgres/username"].value
  environment = "development"
  kms_key_arn = ""
  tags = {
    Name              = "report-a-defect-db-development"
    Environment       = "development"
    terraform-managed = true
    project_name      = "Report a Defect"
  } 
  vpc_id = "vpc-0d15f152935c8716f"
}

# ECS Module
module "aws-ecs-lbh" {
    source = "github.com/LBHackney-IT/aws-ecs-lbh?ref=27607834b4821b01ba0f0fade8e292181fe9658e"
    ecs_service_config = {
        "report-a-defect" = {
          family = "report-a-defect"
          container_definitions = jsonencode([
              {
                  name  = "report-a-defect-container"
                  image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-2.amazonaws.com/hackney/apps/report-a-defect:latest"
                  memory = 2048
                  cpu = 512
                  essential = true
                  portMappings = [{ containerPort = 3000 }]
                  logConfiguration = {
                      logDriver = "awslogs"
                      options = {
                        awslogs-group         = "ecs-task-report-a-defect-development"
                        awslogs-region        = "eu-west-2"
                        awslogs-stream-prefix = "report-a-defect-development-logs"
                      }
                  }
                  environment = [
                      { name = "AUTH0_CLIENT_ID", value = data.aws_ssm_parameter.params["auth0_client_id"].value },
                      { name = "AUTH0_CLIENT_SECRET", value = data.aws_ssm_parameter.params["auth0_client_secret"].value },
                      { name = "AUTH0_DOMAIN", value = data.aws_ssm_parameter.params["auth0_domain"].value },
                      { name = "DATABASE_URL", value = "AAAAAH" },
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
          cpu = 256
          memory = 512
          execution_role_arn = "arn:aws:iam::364864573329:role/ecsTaskExecutionRole"
          task_role_arn = "arn:aws:iam::364864573329:role/ecsTaskExecutionRole"
          launch_type = "FARGATE"        
      }
    }
    application = "report-a-defect"
    environment = "development"
    vpc_id = "vpc-abc123456"
    task_subnets = ["subnet-0140d06fb84fdb547", "subnet-05ce390ba88c42bfd"]
    
    create_alb = true
    create_cluster = true
    alb_access_logs_configuration = {
      access_log_prefix = "ecs-task-report-a-defect-development"
      retention_period = 7
    }
    
    create_ecr_repository = true
    
    listener_port = 80
    listener_protocol = "HTTP"
}