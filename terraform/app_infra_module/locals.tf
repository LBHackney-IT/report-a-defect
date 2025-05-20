locals {
  database_name = "reportadefect"
  database_port = 5432
  database_url  = "postgres://${aws_secretsmanager_secret_version.db_username.secret_string}:${aws_secretsmanager_secret_version.db_password.secret_string}@${aws_db_instance.lbh-db.address}:${local.database_port}/${local.database_name}"
  app_port      = 3000
  redis_port    = 6379
  secret_names = [
    "auth0-client-secret",
    "aws-access-key-id",
    "aws-secret-access-key",
    "database-url-string",
    "notify-key",
    "secret-key-base",
  ]
  ssm_params = [
    "auth0_client_id",
    "auth0_domain",
    "aws_bucket",
    "aws_region",
    "domain",
    "lang",
    "nbt_group_email",
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
    "sms_blacklist",
  ]
  container_definition_base = {
    image     = "${aws_ecr_repository.app_repository.repository_url}:latest"
    essential = true
    secrets = [
      for secret_key, secret_value in data.aws_secretsmanager_secret.secrets :
      {
        name      = upper(replace(secret_key, "-", "_")) # Convert to uppercase and replace dashes with underscores
        valueFrom = secret_value.arn
      }
    ]
    environment = [
      for param_key, param_value in data.aws_ssm_parameter.params :
      {
        name  = upper(param_key) # Convert to uppercase
        value = param_value.value
      }
    ]
  }
}