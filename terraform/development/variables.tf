variable "image_tag" {
  description = "The image tag to use for the ECS task definition."
  type        = string
  default     = "latest"
}
variable "enable_ecs_service" {
  description = "Enable or disable the ECS service."
  type        = bool
  default     = true
}