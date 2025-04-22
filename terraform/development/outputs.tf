
output "ecr_repository_url" {
    description = "value of the ECR repository URL"
    value = module.aws-ecs-lbh.ecr_repository_url
}
