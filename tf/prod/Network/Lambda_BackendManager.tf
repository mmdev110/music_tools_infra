resource "aws_lambda_function" "lambda_backend_manager" {
  function_name = module.constants.lambda_name_manager
  role          = module.lambda_backend_manager_role.iam_role_arn
  image_uri     = "${aws_ecr_repository.lambda_backend_manager.repository_url}:latest"
  package_type  = "Image"
  skip_destroy  = false
  memory_size   = 128
  environment {
    variables = {
      "GITHUB_TOKEN" = aws_ssm_parameter.backend_manager_token.value
    }
  }
}
//コンテナイメージ
data "aws_ecr_image" "lambda_backend_manager" {
  repository_name = module.constants.ecr_repository_name_backend_manager
  image_tag       = "latest"
}

data "aws_iam_policy_document" "lambda_backend_manager" {
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
    effect    = "Allow"
    actions   = ["rds:DescribeDBInstances"]
    resources = [aws_db_instance.db.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["logs:FilterLogEvents"]
    resources = ["${aws_cloudwatch_log_group.backend.arn}:log-stream:"]
  }
}


module "lambda_backend_manager_role" {
  source     = "../../modules/iam_role"
  name       = "music_tools_lambda_backend_manager_role_prod"
  identifier = "lambda.amazonaws.com"
  policy     = data.aws_iam_policy_document.lambda_backend_manager.json
}

//API Gatewayからの実行を許可
resource "aws_lambda_permission" "allow_from_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_backend_manager.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.backend_manager.execution_arn}/*/*${local.api_route}"
}