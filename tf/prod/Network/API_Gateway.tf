locals {
  api_route = "/backend_manager"
}

resource "aws_apigatewayv2_domain_name" "backend_manager" {
  domain_name = module.constants.backend_manager_domain

  domain_name_configuration {
    certificate_arn = aws_acm_certificate_validation.backend.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}
resource "aws_apigatewayv2_api" "backend_manager" {
  name          = module.constants.lambda_name_manager
  protocol_type = "HTTP"
  cors_configuration {
    allow_credentials = true
    allow_headers     = ["accept", "content-type", "x-csrf-token"]
    allow_methods     = ["GET", "OPTIONS", "POST"]
    allow_origins     = ["https://${module.constants.frontend_domain}"]
  }
}

resource "aws_apigatewayv2_integration" "backend_manager" {
  api_id           = aws_apigatewayv2_api.backend_manager.id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  description            = "lambda backend_manager integration"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.lambda_backend_manager.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "backend_manager" {
  api_id             = aws_apigatewayv2_api.backend_manager.id
  route_key          = "POST ${local.api_route}"
  authorization_type = "NONE"

  target = "integrations/${aws_apigatewayv2_integration.backend_manager.id}"
}

resource "aws_apigatewayv2_api_mapping" "backend_manager" {
  api_id      = aws_apigatewayv2_api.backend_manager.id
  domain_name = aws_apigatewayv2_domain_name.backend_manager.id
  stage       = "$default"
}


resource "aws_route53_record" "backend_manager" {
  allow_overwrite = true
  name            = module.constants.backend_manager_domain
  //ttl             = 0
  type    = "A"
  zone_id = aws_route53_zone.example.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_apigatewayv2_domain_name.backend_manager.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.backend_manager.domain_name_configuration[0].hosted_zone_id
  }
}