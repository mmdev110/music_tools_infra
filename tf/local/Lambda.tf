resource "aws_lambda_function" "lambda" {
  function_name = module.constants.lambda_function_name
  role          = module.lambda_role.iam_role_arn
  image_uri     = "${aws_ecr_repository.repository.repository_url}@${data.aws_ecr_image.lambda.image_digest}"
  package_type  = "Image"
  skip_destroy  = false
  memory_size   = 128
  environment {
    variables = {
      "MEDIACONVERT_ENDPOINT"          = data.aws_ssm_parameter.mediaconvert_endpoint.value
      "MEDIACONVERT_JOB_ROLE_ARN"      = module.mediaconvert_role.iam_role_arn
      "MEDIACONVERT_JOB_TEMPLATE_NAME" = local.mediaconvert_job_template_name
      "REGION"                         = local.mediaconvert_region
    }
  }
}
//lambdaイメージ
data "aws_ecr_image" "lambda" {
  repository_name = module.constants.ecr_repository_name
  image_tag       = "latest"
}
data "aws_iam_policy_document" "lambda" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup"]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]
    //resources = ["arn:aws:logs:ap-northeast-1:138767642386:log-group:/aws/lambda/music_tools_convert_local:*"]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = ["mediaconvert:CreateJob"]
    //resources = ["arn:aws:logs:ap-northeast-1:138767642386:log-group:/aws/lambda/music_tools_convert_local:*"]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = ["iam:PassRole"]
    //resources = ["arn:aws:logs:ap-northeast-1:138767642386:log-group:/aws/lambda/music_tools_convert_local:*"]
    resources = [module.mediaconvert_role.iam_role_arn]
  }
}


module "lambda_role" {
  source     = "../modules/iam_role"
  name       = "music_tools_lambda_role_local"
  identifier = "lambda.amazonaws.com"
  policy     = data.aws_iam_policy_document.lambda.json
}

//s3バケットからの通知を許可
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.usermedia.arn
}