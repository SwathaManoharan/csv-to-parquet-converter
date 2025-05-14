data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda_src"
  output_path = "${path.module}/lambda_function_payload.zip"
}

resource "aws_lambda_function" "csv_to_parquet" {
  function_name = "csv-to-parquet-converter"
  role          = var.lambda_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = data.archive_file.lambda_zip.output_path
  timeout       = 60
  memory_size   = 256

  environment {
    variables = {
      DEST_BUCKET     = var.destination_bucket_name
      SES_EMAIL_TO    = var.notification_email
      SOURCE_BUCKET   = var.source_bucket_name
    }
  }

  depends_on = [var.lambda_role_arn]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_to_parquet.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.source_bucket_name}"
}
