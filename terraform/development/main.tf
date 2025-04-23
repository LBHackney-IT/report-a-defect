provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      Application = "Report a Defect"
      TeamEmail   = "mmh-project-team@hackney.gov.uk" # Note: To change once HPT email is confirmed
      Environment = "dev"
    }
  }
}

terraform {
  backend "s3" {
    bucket  = "terraform-state-housing-development"
    encrypt = true
    region  = "eu-west-2"
    key     = "services/lbh-report-a-defect/state"
  }
}

data "aws_caller_identity" "current" {}

locals {
  environment_name         = "development"
  database_name            = "reportadefect"
  database_port            = 5432
  database_url             = "postgres://${aws_secretsmanager_secret_version.db_username.secret_string}:${aws_secretsmanager_secret_version.db_password.secret_string}@${module.lbh-db-postgres.instance_id}.eu-west-2.rds.amazonaws.com:local.database_port/reportadefect"

}