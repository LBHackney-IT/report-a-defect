# Configures S3 buckets used by the application, used for images and other static assets.

# TODO: Currently, the S3 bucket is not being used. We're using an s3 bucket in another account, but this is set up for future use.

# resource "aws_s3_bucket" "image_bucket" {
#   bucket = "report-a-defect-images-${var.environment_name}"
# }
# resource "aws_s3_bucket_policy" "image_bucket_policy" {
#   bucket = aws_s3_bucket.image_bucket.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement : [{
#       Sid    = "AllowEcsTaskReadWriteAccess",
#       Effect = "Allow",
#       Principal = {
#         Service = "ecs-tasks.amazonaws.com"
#       },
#       Action = [
#         "s3:PutObject",
#         "s3:GetObject",
#         "s3:DeleteObject",
#       ],
#       Resource = "${aws_s3_bucket.image_bucket.arn}/*",
#       Condition = {
#         StringEquals = {
#           "AWS:SourceArn" = aws_ecs_task_definition.app_task.arn
#         }
#       }
#       },
#       {
#         Sid    = "AllowCloudFrontReadOnlyAccess",
#         Effect = "Allow",
#         Principal = {
#           Service = "cloudfront.amazonaws.com"
#         },
#         Action = [
#           "s3:GetObject",
#         ],
#         Resource = "${aws_s3_bucket.image_bucket.arn}/*",
#         Condition = {
#           StringEquals = {
#             "AWS:SourceArn" = aws_cloudfront_distribution.app_distribution.arn
#           }
#         }
#     }]
#   })
# }
# resource "aws_s3_bucket_cors_configuration" "image_bucket_cors" {
#   bucket = aws_s3_bucket.image_bucket.id
#   cors_rule {
#     allowed_headers = ["*"]
#     allowed_methods = ["GET", "PUT", "POST", "DELETE"]
#     allowed_origins = [aws_lb.nlb.dns_name, aws_cloudfront_distribution.app_distribution.domain_name]
#     expose_headers  = ["ETag"]
#     max_age_seconds = 3000
#   }
# }
# resource "aws_ssm_parameter" "bucket_name" {
#   name        = "/report-a-defect/${var.environment_name}/aws_bucket"
#   type        = "String"
#   value       = aws_s3_bucket.image_bucket.bucket
#   description = "S3 bucket name for report-a-defect images"
#   overwrite   = true
# }