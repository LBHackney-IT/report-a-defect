# Get existing VPC and Subnets
data "aws_vpc" "main_vpc" {
  tags = {
    Name = var.vpc_name
  }
}
data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main_vpc.id]
  }
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}
data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main_vpc.id]
  }
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

# DB Subnet
resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.database_name}-db-subnet"
  subnet_ids = data.aws_subnets.private_subnets.ids

  lifecycle {
    create_before_destroy = true
  }
}

# DB Security Group
data "aws_security_group" "bastion_sg" {
  filter {
    name   = "group-name"
    values = ["PlatformAPIsBastionSecurityGroup"]
  }
}
resource "aws_security_group" "db_security_group" {
  vpc_id      = data.aws_vpc.main_vpc.id
  name_prefix = "allow_${var.database_name}_db_traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all outbound traffic"
  }
}
resource "aws_security_group_rule" "allow_ecs_to_rds" {
  type                     = "ingress"
  from_port                = var.database_port
  to_port                  = var.database_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_security_group.id
  source_security_group_id = aws_security_group.ecs_task_sg.id
  description              = "Allow ECS tasks to talk to Postgres"
}
resource "aws_security_group_rule" "allow_bastion_to_rds" {
  type                     = "ingress"
  from_port                = var.database_port
  to_port                  = var.database_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_security_group.id
  source_security_group_id = data.aws_security_group.bastion_sg.id
  description              = "Allow Bastion access to RDS"
}

# ECS Security Group
resource "aws_security_group" "ecs_task_sg" {
  name        = "report-a-defect-ecs-task-sg"
  description = "Security group for report a defect ECS tasks"
  vpc_id      = data.aws_vpc.main_vpc.id
}
resource "aws_security_group_rule" "allow_outbound_to_secrets_manager" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs_task_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow outbound traffic to Secrets Manager"
}
resource "aws_security_group_rule" "allow_inbound_from_db" {
  type                     = "ingress"
  from_port                = var.database_port
  to_port                  = var.database_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_task_sg.id
  source_security_group_id = aws_security_group.db_security_group.id
  description              = "allow inbound traffic from the DB security group"
}
resource "aws_security_group_rule" "allow_inbound_from_lb" {
  type                     = "ingress"
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_task_sg.id
  source_security_group_id = aws_security_group.lb_sg.id
  description              = "allow inbound traffic from the load balancer"
}
resource "aws_security_group_rule" "allow_bastion_to_ecs" {
  type                     = "ingress"
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_task_sg.id
  source_security_group_id = data.aws_security_group.bastion_sg.id
  description              = "Allow Bastion access to ECS tasks"
}

# LB security group
resource "aws_security_group" "lb_sg" {
  name        = "report-a-defect-lb-sg"
  description = "Security group for report a defect NLB"
  vpc_id      = data.aws_vpc.main_vpc.id

  ingress {
    description = "allow all inbound traffic from the VPC"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main_vpc.cidr_block]
  }
  egress {
    description     = "allow outbound traffic to the ECS tasks"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_task_sg.id]
  }
}

# Network Load Balancer (NLB) setup
resource "aws_lb" "nlb" {
  name                       = "nlb-report-a-defect"
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = data.aws_subnets.private_subnets.ids
  security_groups            = [aws_security_group.lb_sg.id, "sg-00d2e14f38245dd0b"]
  enable_deletion_protection = false
}
resource "aws_lb_target_group" "lb_target_group" {
  depends_on  = [aws_lb.nlb]
  name        = "tg-report-a-defect-${var.environment_name}"
  port        = var.app_port
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.main_vpc.id
  target_type = "ip"
  stickiness {
    enabled = true
    type    = "source_ip"
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb_listener" "lb_listener" {
  depends_on        = [aws_lb.nlb]
  load_balancer_arn = aws_lb.nlb.id
  port              = var.app_port
  protocol          = "TCP"
  # Redirect all traffic from the NLB to the target group
  default_action {
    target_group_arn = aws_lb_target_group.lb_target_group.id
    type             = "forward"
  }
}

# API Gateway

# VPC Link
resource "aws_api_gateway_vpc_link" "this" {
  depends_on  = [aws_lb.nlb]
  name        = "vpc-link-report-a-defect-fe"
  target_arns = [aws_lb.nlb.arn]
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "api_gateway_log_group" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.main.id}/${var.environment_name}"
  retention_in_days = 7
}


# API Gateway, Private Integration with VPC Link
# and deployment of a single resource that will take ANY
# HTTP method and proxy the request to the NLB
resource "aws_api_gateway_rest_api" "main" {
  name = "development-report-a-defect"
}

# Add a proxy resource to the API Gateway
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
    "method.request.path.proxy"    = true
    "method.request.header.Cookie" = true
  }
}
resource "aws_api_gateway_integration" "main" {
  depends_on  = [aws_lb.nlb, aws_api_gateway_vpc_link.this]
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method
  request_parameters = {
    "integration.request.path.proxy"    = "method.request.path.proxy"
    "integration.request.header.Cookie" = "method.request.header.Cookie"
  }
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.nlb.dns_name}:${var.app_port}/{proxy}"
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.this.id
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  depends_on  = [aws_api_gateway_integration.main]
  variables = {
    # just to trigger redeploy on resource changes
    resources = join(", ", [aws_api_gateway_resource.main.id, aws_api_gateway_rest_api.main.root_resource_id])
    # note: redeployment might be required with other gateway changes.
    # when necessary run `terraform taint <this resource's address>`
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  depends_on    = [aws_api_gateway_deployment.main, aws_cloudwatch_log_group.api_gateway_log_group]
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.environment_name
  deployment_id = aws_api_gateway_deployment.main.id
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  method_path = "*/*"

  settings {
    logging_level      = "INFO"
    metrics_enabled    = true
    data_trace_enabled = true
  }
}


# Cloudfront Distribution
resource "aws_cloudfront_distribution" "app_distribution" {
  origin {
    domain_name = replace(aws_api_gateway_stage.main.invoke_url, "/^https?://([^/]*).*/", "$1")
    origin_id   = "api-gateway-origin"
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

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "api-gateway-origin"

    forwarded_values {
      headers      = ["*"]
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