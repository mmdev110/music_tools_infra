
resource "aws_ssm_parameter" "mediaconvert_endpoint" {
  name        = "/music_tools/local/backend/mediaconvert_endpoint"
  value       = "replace me"
  type        = "SecureString"
  description = "mediaconvert_endpoint for local"
  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "google_oauth_client_id" {
  name        = "/music_tools/local/frontend/google_oauth_client_id"
  value       = "replace me"
  type        = "SecureString"
  description = "google_oauth_client_id for local environment"
  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "google_oauth_client_secret" {
  name        = "/music_tools/local/frontend/google_oauth_client_secret"
  value       = "replace me"
  type        = "SecureString"
  description = "google_oauth_client_secret for local environment"
  lifecycle {
    ignore_changes = [value]
  }
}