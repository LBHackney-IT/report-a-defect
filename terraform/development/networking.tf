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

# DB Subnet + Security Group
resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.database_name}-db-subnet"
  subnet_ids = data.aws_subnets.private_subnets.ids

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "db_security_group" {
  vpc_id      = data.aws_vpc.main_vpc.id
  name_prefix = "allow_${var.database_name}_db_traffic"

  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow inbound traffic"
    from_port   = var.database_port
    to_port     = var.database_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ECS Security Group
resource "aws_security_group" "ecs_task_sg" {
  name        = "report-a-defect-ecs-sg"
  description = "Security group for report a defect ECS tasks"
  vpc_id      = data.aws_vpc.main_vpc.id

  egress {
    description = "allow all outbound traffic for Secrets Manager"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow all inbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   description = "allow inbound traffic from the VPC"
  #   from_port       = 5432
  #   to_port         = 5432
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.db_security_group.id]
  # }

  # ingress {
  #   description = "allow inbound traffic from the load balancer"
  #   from_port   = 3000
  #   to_port     = 3000
  #   protocol    = "tcp"
  #   cidr_blocks = [data.aws_vpc.main_vpc.cidr_block]
  # }
}

# Network Load Balancer (NLB) setup
resource "aws_lb" "lb" {
  name                       = "report-a-defect-lb"
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = data.aws_subnets.public_subnets.ids
  enable_deletion_protection = false
}
resource "aws_lb_target_group" "lb_tg" {
  depends_on  = [aws_lb.lb]
  name_prefix = "rd-tg-"
  port        = var.app_port
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.main_vpc.id
  target_type = "ip"
  health_check {
    protocol = "HTTP"
    port     = "traffic-port" 
    path     = "/check"  # The path to the health check route
    interval = 30
    timeout  = 5  
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
  stickiness {
    enabled = false
    type    = "source_ip"
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.id
  port              = var.app_port
  protocol          = "TCP"
  # Redirect all traffic from the NLB to the target group
  default_action {
    target_group_arn = aws_lb_target_group.lb_tg.id
    type             = "forward"
  }
}

# API Gateway

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
# Add proxy to the root resource
resource "aws_api_gateway_method" "root" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_rest_api.main.root_resource_id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = false
  request_parameters = {
    "method.request.path.proxy" = true
  }
}
resource "aws_api_gateway_integration" "root" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_rest_api.main.root_resource_id
  http_method = aws_api_gateway_method.root.http_method
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.lb.dns_name}:${var.app_port}/{proxy}"
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.this.id
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
  uri                     = "http://${aws_lb.lb.dns_name}:${var.app_port}/{proxy}"
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.this.id
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  depends_on = [
    aws_api_gateway_integration.root,
    aws_api_gateway_integration.main
  ]
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
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "development"
  deployment_id = aws_api_gateway_deployment.main.id
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