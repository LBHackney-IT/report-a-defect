
output "ecr_repository_url" {
  description = "value of the ECR repository URL"
  value       = module.aws-ecs-lbh.ecr_repository_url
}

output "ecr_repo_url_2" {
  description = "value of the ECR repository URL"
  value       = aws_ecr_repository.app_repository.repository_url
}