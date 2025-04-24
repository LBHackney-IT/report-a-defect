output "ecr_repository_url" {
  description = "value of the ECR repository URL"
  value       = aws_ecr_repository.app_repository.repository_url
}

output "cluster_name" {
  description = "value of the ECS cluster name"
  value       = aws_ecs_cluster.app_cluster.name
}

output "service_name" {
  description = "value of the ECS service name"
  value       = aws_ecs_service.app_service.name
}