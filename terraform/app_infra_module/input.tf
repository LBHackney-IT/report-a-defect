variable "environment_name" {
  description = "The name of the environment (e.g., development, staging, prod)"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC in the account"
  type        = string
}

variable "lb_security_group_id" {
  description = "The additional security group ID for the load balancer"
  type        = string
}

variable "bastion_sg_id" {
  description = "The security group ID for the bastion host"
  type        = string
}

variable "environment_name_tag" {
  description = "The environment name for tagging resources (not the same as environment_name)"
  type        = string
}

variable "cname_aliases" {
  description = "CNAME aliases for the CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "use_cloudfront_cert" {
  description = "Whether to use a CloudFront certificate"
  type        = bool
  default     = false
}

variable "hackney_cert_arn" {
  description = "The ARN of the ACM certificate for the CloudFront distribution"
  type        = string
  default     = ""
}
