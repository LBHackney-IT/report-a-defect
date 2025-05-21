terraform {
  backend "s3" {
    bucket  = "terraform-state-housing-production"
    encrypt = true
    region  = "eu-west-2"
    key     = "services/lbh-report-a-defect/state"
  }
}


data "aws_acm_certificate" "hackney_cert" {
  domain   = "lbh-report-a-defect.hackney.gov.uk.com"
  statuses = ["ISSUED"]
}


module "main" {
  source               = "../app_infra_module"
  environment_name     = "production"
  vpc_name             = "housing-prod"
  lb_security_group_id = "sg-01396d0029aa1c950"
  bastion_sg_id        = "sg-080ea6ec2415dea47"
  environment_name_tag = "prod"
  
  cname_aliases        = ["lbh-report-a-defect.hackney.gov.uk.com"]
  hackney_cert_arn     = data.aws_acm_certificate.hackney_cert.arn
}


# Pass all outputs from the module to the root module

output "ecr_repository_url" {
  description = "value of the ECR repository URL"
  value       = module.main.ecr_repository_url
}

output "cluster_name" {
  description = "value of the ECS cluster name"
  value       = module.main.cluster_name
}

output "service_name" {
  description = "value of the ECS service name"
  value       = module.main.service_name
}

output "worker_task_definition_name" {
  description = "value of the ECS task definition name for the worker"
  value       = module.main.worker_task_definition_name
}

output "worker_container_name" {
  description = "value of the ECS container name for the worker"
  value       = module.main.worker_container_name
}

output "subnet_ids" {
  description = "value of the subnet IDs"
  value       = module.main.subnet_ids
}

output "ecs_security_group_ids" {
  description = "value of the ECS security group IDs"
  value       = module.main.ecs_security_group_ids
}