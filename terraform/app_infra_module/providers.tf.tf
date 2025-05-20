terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      Application = "Report a Defect"
      TeamEmail   = "mmh-project-team@hackney.gov.uk" # Note: To change once HPT email is confirmed
      Environment = var.environment_name_tag
    }
  }
}