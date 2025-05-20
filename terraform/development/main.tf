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
  bastion_sg_id        = "sg-07fc77dda64f4b948"
  environment_name_tag = "dev"
  use_cloudfront_cert  = true
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