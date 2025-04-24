resource "aws_ecr_repository" "app_repository" {
  name                 = "report-a-defect-ecr-dev"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository_policy" "app_policy" {
  repository = aws_ecr_repository.app_repository.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "logs:CreateLogGroup"
        ]
      }
    ]
  }
  EOF
}

resource "aws_ecs_service" "app_service" {
  name            = "report-a-defect-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.development_public_subnets.ids
    security_groups  = ["sg-00d2e14f38245dd0b"]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    container_name   = "report-a-defect-app-container"
    container_port   = local.app_port
  }
}

resource "aws_ecs_task_definition" "app_task" {
  depends_on               = [aws_cloudwatch_log_group.report_a_defect]
  family                   = "ecs-task-definition-report-a-defect"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "report-a-defect-app-container"
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

# Network Load Balancer (NLB) setup
resource "aws_lb" "lb" {
  name                       = "lb-report-a-defect"
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = data.aws_subnets.development_public_subnets.ids
  enable_deletion_protection = false
}
resource "aws_lb_target_group" "lb_tg" {
  depends_on  = [aws_lb.lb]
  name_prefix = "rd-tg-"
  port        = local.app_port
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.development_vpc.id
  target_type = "ip"
  stickiness {
    enabled = false
    type    = "source_ip"
  }
  lifecycle {
    create_before_destroy = true
  }
}
# Redirect all traffic from the NLB to the target group
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.id
  port              = local.app_port
  protocol          = "TCP"
  default_action {
    target_group_arn = aws_lb_target_group.lb_tg.id
    type             = "forward"
  }
}

# API Gateway setup

# VPC Link
resource "aws_api_gateway_vpc_link" "this" {
  name        = "vpc-link-report-a-defect-fe"
  target_arns = [aws_lb.lb.arn]
}

# API Gateway, Private Integration with VPC Link
# and deployment of a single resource that will take ANY
# HTTP method and proxy the request to the NLB
resource "aws_api_gateway_rest_api" "main" {
  name = "development-report-a-defect"
}

resource "aws_api_gateway_resource" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "main" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.main.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = false
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.lb.dns_name}:${local.app_port}/{proxy}"
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.this.id
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  depends_on  = [aws_api_gateway_integration.main]
  variables = {
    # just to trigger redeploy on resource changes
    resources = join(", ", [aws_api_gateway_resource.main.id])
    # note: redeployment might be required with other gateway changes.
    # when necessary run `terraform taint <this resource's address>`
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Cloudfront Distribution
locals {
  origin_id = "report-a-defect-origin"
}

resource "aws_cloudfront_distribution" "app_distribution" {
  origin {
    domain_name = replace(aws_api_gateway_deployment.main.invoke_url, "/^https?://([^/]*).*/", "$1")
    origin_id   = local.origin_id
    origin_path = "/development"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  aliases         = []
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Distribution for report a defect front end"

  //  aliases = ["a valid url"] - probably not needed for dev but we'll need a proper url for production

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "development"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}