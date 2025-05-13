# Configures EventBridge to trigger scheduled tasks like the notify rake jobs.
# Used to automate ECS task executions based on scheduled events or rules.

resource "aws_cloudwatch_event_rule" "worker_schedule" {
  name                = "report-a-defect-worker-schedule"
  description         = "Schedule to run the worker task for report-a-defect"
  schedule_expression = "cron(0 7 * * ? *)" # 7AM UTC daily
}
resource "aws_cloudwatch_event_target" "worker_target" {
  rule      = aws_cloudwatch_event_rule.worker_schedule.name
  target_id = "report-a-defect-worker-target"
  arn       = aws_ecs_cluster.app_cluster.arn
  role_arn  = aws_iam_role.eventbridge_invoke_ecs.arn

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.worker_task.arn
    launch_type         = "FARGATE"
    platform_version    = "LATEST"

    network_configuration {
      subnets          = data.aws_subnets.public_subnets.ids
      security_groups  = [aws_security_group.ecs_task_sg.id]
      assign_public_ip = false
    }
  }
}