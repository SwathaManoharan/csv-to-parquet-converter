variable "aws_region" {}
variable "source_bucket_name" {}
variable "destination_bucket_name" {}
variable "notification_email" {}
variable "github_oauth_token" {
  description = "GitHub OAuth Token with repo access"
  sensitive   = true
}

