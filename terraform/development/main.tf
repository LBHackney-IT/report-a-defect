terraform {
  backend "s3" {
    bucket  = "terraform-state-housing-development"
    encrypt = true
    region  = "eu-west-2"
    key     = "services/lbh-report-a-defect/state"
  }
}

module "main" {
  source               = "../app_infra_module"
  environment_name     = "development"
  vpc_name             = "housing-dev"
  lb_security_group_id = "sg-00d2e14f38245dd0b"
  environment_name_tag = "dev"
}

resource "aws_ecr_repository" "app_repository" {
  name                 = "report-a-defect-ecr-development"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}