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

variable "environment_name_tag" {
  description = "The environment name for tagging resources (not the same as environment_name)"
  type        = string
}