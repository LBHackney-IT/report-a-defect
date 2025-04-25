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

output "task_definition_name" {
  description = "value of the ECS task definition name"
  value       = aws_ecs_task_definition.app_task.family
}

output "subnet_ids" {
  description = "value of the subnet IDs"
  value       = data.aws_subnets.private_subnets.ids
}

output "ecs_security_group_ids" {
  description = "value of the ECS security group IDs"
  value       = aws_security_group.ecs_task_sg.id
}