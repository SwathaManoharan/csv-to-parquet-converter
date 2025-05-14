provider "aws" {
  region = "ap-south-1"
}


module "lambda" {
  source                  = "./modules/lambda"
  source_bucket_name      = var.source_bucket_name
  destination_bucket_name = var.destination_bucket_name
  lambda_role_arn         = module.iam.lambda_role_arn
  notification_email      = var.notification_email
}


module "s3" {
  source                 = "./modules/s3"
  source_bucket_name     = var.source_bucket_name
  destination_bucket_name = var.destination_bucket_name
  lambda_function_arn    = module.lambda.lambda_arn
  lambda_permission      = module.lambda.lambda_permission
}

module "ses" {
  source        = "./modules/ses"
  email_address = var.notification_email
}


module "iam" {
  source = "./modules/iam"

  source_bucket_name      = var.source_bucket_name
  destination_bucket_name = var.destination_bucket_name
}

module "codepipeline" {
  source               = "./modules/codepipeline"
  project_name         = "csv-to-parquet"
  github_repo_url      = "https://github.com/SwathaManoharan/csv-to-parquet-converter.git"
  github_owner         = "SwathaManoharan"
  github_repo_name     = "csv-to-parquet-converter"
  github_branch        = "main"
  repo_token = var.repo_token
}

