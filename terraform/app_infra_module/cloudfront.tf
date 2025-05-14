# Configures the CloudFront distribution to serve content from API Gateway.
# Manages the content delivery network (CDN) layer in front of the application.

resource "aws_cloudfront_distribution" "app_distribution" {
  origin {
    domain_name = replace(aws_api_gateway_stage.main.invoke_url, "/^https?://([^/]*).*/", "$1")
    origin_id   = "api-gateway-origin"
    origin_path = "/${var.environment_name}"
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
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "api-gateway-origin"
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # AllViewerExceptHostHeader
    min_ttl                  = 0
    default_ttl              = 0
    max_ttl                  = 0
    compress                 = true
    viewer_protocol_policy   = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_ssm_parameter" "app_domain_name" {
  name        = "/report-a-defect/${var.environment_name}/domain_name"
  description = "Domain name for the report a defect app"
  type        = "String"
  value       = aws_cloudfront_distribution.app_distribution.domain_name
  overwrite   = true
}