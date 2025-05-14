# Defines the external entry points into the application: NLB, API Gateway, and VPC Link.
# These resources handle traffic routing to ECS services and integration with other AWS services.

# Network Load Balancer (NLB) setup
resource "aws_lb" "nlb" {
  name                       = "nlb-report-a-defect"
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = data.aws_subnets.private_subnets.ids
  security_groups            = [aws_security_group.lb_sg.id, var.lb_security_group_id]
  enable_deletion_protection = false
}
resource "aws_lb_target_group" "lb_target_group" {
  depends_on  = [aws_lb.nlb]
  name        = "tg-report-a-defect-${var.environment_name}"
  port        = local.app_port
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
  port              = local.app_port
  protocol          = "TCP"
  # Redirect all traffic from the NLB to the target group
  default_action {
    target_group_arn = aws_lb_target_group.lb_target_group.id
    type             = "forward"
  }
}

# VPC Link
resource "aws_api_gateway_vpc_link" "this" {
  depends_on  = [aws_lb.nlb]
  name        = "vpc-link-report-a-defect-fe"
  target_arns = [aws_lb.nlb.arn]
}

# API Gateway with VPC Link (connected to NLB)
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
  uri                     = "http://${aws_lb.nlb.dns_name}:${local.app_port}/{proxy}"
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
  depends_on    = [aws_api_gateway_deployment.main]
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.environment_name
  deployment_id = aws_api_gateway_deployment.main.id
}