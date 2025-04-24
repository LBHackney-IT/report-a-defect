 output "ecr_repository_url" {
  description = "value of the ECR repository URL"
  value       = aws_ecr_repository.app_repository.repository_url
}