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
  environment_name = "development"
}