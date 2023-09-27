resource "aws_cognito_user_pool" "auth" {
  name                = module.constants.cognito_user_pool_name
  username_attributes = ["email"]
  admin_create_user_config {
    allow_admin_create_user_only = false
  }
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
  user_attribute_update_settings {
    attributes_require_verification_before_update = [
      "email"
    ]
  }
  username_configuration {
    case_sensitive = false
  }
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  auto_verified_attributes = ["email"]
  deletion_protection      = "ACTIVE"
  email_configuration {
    email_sending_account = "DEVELOPER"
    from_email_address    = module.constants.support_email_address
    source_arn            = data.aws_ses_domain_identity.email.arn
  }


}

resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.auth.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes              = "profile email openid"
    client_id                     = aws_ssm_parameter.google_oauth_client_id.value
    client_secret                 = aws_ssm_parameter.google_oauth_client_secret.value
    attributes_url                = ""
    attributes_url_add_attributes = true
    authorize_url                 = ""
    oidc_issuer                   = ""
    token_request_method          = ""
    token_url                     = ""
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
  lifecycle {
    ignore_changes = [
      //以下は自動生成される値だが、差分出てしまうのでignore_changesに追記する
      provider_details["attributes_url"],
      provider_details["attributes_url_add_attributes"],
      provider_details["authorize_url"],
      provider_details["oidc_issuer"],
      provider_details["token_request_method"],
      provider_details["token_url"],
    ]
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name         = module.constants.cognito_user_pool_name
  user_pool_id = aws_cognito_user_pool.auth.id
  callback_urls = [
    "https://music-tools.ys-dev.net",
    "https://music-tools.ys-dev.net/auth",
  ]
  logout_urls = [
    "https://music-tools.ys-dev.net",
    "https://music-tools.ys-dev.net/auth",
  ]
  access_token_validity  = 5
  auth_session_validity  = 3
  id_token_validity      = 5
  refresh_token_validity = 30
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes = [
    "email", "openid", "phone"
  ]
  enable_token_revocation = true
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
  prevent_user_existence_errors = "ENABLED"
  supported_identity_providers = [
    "COGNITO", "Google"
  ]

}
resource "aws_cognito_user_pool_domain" "auth" {
  domain       = module.constants.cognito_user_pool_name
  user_pool_id = aws_cognito_user_pool.auth.id
}