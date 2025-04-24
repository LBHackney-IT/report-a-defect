variable "environment_name" {
  type    = string
  default = "development"
}
variable "database_name" {
  type    = string
  default = "reportadefect"
}
variable "database_port" {
  type    = number
  default = 5432
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "secret_names" {
  type = list(string)
  default = [
    "aws-access-key-id",
    "aws-secret-access-key",
    "auth0-client-secret",
    "new-relic-license-key",
    "notify-key",
    "papertrail-api-token",
    "secret-key-base"
  ]
}
variable "ssm_params" {
  type = list(string)
  default = [
    "auth0_client_id",
    "auth0_domain",
    "aws_bucket",
    "aws_region",
    "database-url",
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