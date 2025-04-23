resource "aws_ecr_repository" "app_repository" {
  name = "report-a-defect-ecr-development"
}

resource "aws_ecs_task_definition" "app_task" {
  depends_on               = [aws_cloudwatch_log_group.report_a_defect]
  family                   = "report-a-defect-task"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "report-a-defect-container"
      image     = "${aws_ecr_repository.app_repository.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = local.app_port
          hostPort      = local.app_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.report_a_defect.name}"
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = "report-a-defect-${local.environment_name}-logs"
        }
      }
      secrets = [{
        name      = "DATABASE_URL"
        valueFrom = data.aws_secretsmanager_secret.secrets["database-url"].arn
        },
        {
          name      = "AWS_ACCESS_KEY_ID"
          valueFrom = data.aws_secretsmanager_secret.secrets["aws-access-key-id"].arn
        },
        {
          name      = "AWS_SECRET_ACCESS_KEY"
          valueFrom = data.aws_secretsmanager_secret.secrets["aws-secret-access-key"].arn
        },
        {
          name      = "AUTH0_CLIENT_SECRET"
          valueFrom = data.aws_secretsmanager_secret.secrets["auth0-client-secret"].arn
        },
        {
          name      = "NEW_RELIC_LICENSE_KEY"
          valueFrom = data.aws_secretsmanager_secret.secrets["new-relic-license-key"].arn
        },
        {
          name      = "NOTIFY_KEY"
          valueFrom = data.aws_secretsmanager_secret.secrets["notify-key"].arn
        },
        {
          name      = "PAPERTRAIL_API_TOKEN"
          valueFrom = data.aws_secretsmanager_secret.secrets["papertrail-api-token"].arn
        },
        {
          name      = "SECRET_KEY_BASE"
          valueFrom = data.aws_secretsmanager_secret.secrets["secret-key-base"].arn
      }]
      environment = [
        { name = "AWS_REGION", value = data.aws_ssm_parameter.params["aws_region"].value },
        { name = "AWS_BUCKET", value = data.aws_ssm_parameter.params["aws_bucket"].value },
        { name = "AUTH0_CLIENT_ID", value = data.aws_ssm_parameter.params["auth0_client_id"].value },
        { name = "AUTH0_DOMAIN", value = data.aws_ssm_parameter.params["auth0_domain"].value },
        { name = "HTTP_PASS", value = data.aws_ssm_parameter.params["http_pass"].value },
        { name = "HTTP_USER", value = data.aws_ssm_parameter.params["http_user"].value },
        { name = "LANG", value = data.aws_ssm_parameter.params["lang"].value },
        { name = "NBT_GROUP_EMAIL", value = data.aws_ssm_parameter.params["nbt_group_email"].value },
        { name = "NEW_RELIC_LOG", value = data.aws_ssm_parameter.params["new_relic_log"].value },
        { name = "NOTIFY_DAILY_DUE_SOON_TEMPLATE", value = data.aws_ssm_parameter.params["notify_daily_due_soon_template"].value },
        { name = "NOTIFY_DAILY_ESCALATION_TEMPLATE", value = data.aws_ssm_parameter.params["notify_daily_escalation_template"].value },
        { name = "NOTIFY_DEFECT_ACCEPTED_BY_CONTRACTOR_TEMPLATE", value = data.aws_ssm_parameter.params["notify_defect_accepted_by_contractor_template"].value },
        { name = "NOTIFY_DEFECT_COMPLETED_TEMPLATE", value = data.aws_ssm_parameter.params["notify_defect_completed_template"].value },
        { name = "NOTIFY_DEFECT_SENT_TO_CONTRACTOR_TEMPLATE", value = data.aws_ssm_parameter.params["notify_defect_sent_to_contractor_template"].value },
        { name = "NOTIFY_FORWARD_DEFECT_TEMPLATE", value = data.aws_ssm_parameter.params["notify_forward_defect_template"].value },
        { name = "RACK_ENV", value = data.aws_ssm_parameter.params["rack_env"].value },
        { name = "RAILS_ENV", value = data.aws_ssm_parameter.params["rails_env"].value },
        { name = "RAILS_LOG_TO_STDOUT", value = data.aws_ssm_parameter.params["rails_log_to_stdout"].value },
        { name = "RAILS_SERVE_STATIC_FILES", value = data.aws_ssm_parameter.params["rails_serve_static_files"].value },
        { name = "REDIS_URL", value = data.aws_ssm_parameter.params["redis_url"].value },
        { name = "SENTRY_DSN", value = data.aws_ssm_parameter.params["sentry_dsn"].value },
        { name = "SMS_BLACKLIST", value = data.aws_ssm_parameter.params["sms_blacklist"].value }
      ]
    }
  ])
}

resource "aws_ecs_cluster" "app_cluster" {
  name = "report-a-defect-cluster"
}

resource "aws_lb" "app_alb" {
  name                       = "report-a-defect-alb"
  internal                   = false # public ALB
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = data.aws_subnets.development_public_subnets.ids
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "app_tg" {
  name     = "report-a-defect-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.development_vpc.id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_ecs_service" "app_service" {
  name            = "report-a-defect-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.development_public_subnets.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "report-a-defect-app-container"
    container_port   = 3000
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "report-a-defect-alb-sg"
  description = "Allow inbound traffic to the ALB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "report-a-defect-ecs-sg"
  description = "Allow ECS tasks to receive traffic from ALB"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
}
