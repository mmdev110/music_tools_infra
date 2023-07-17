
resource "aws_ssm_parameter" "mediaconvert_endpoint" {
  name        = "/music-tools/local/backend/mediaconvert_endpoint"
  value       = "replace me"
  type        = "SecureString"
  description = "mediaconvert_endpoint for local"
  lifecycle {
    ignore_changes = [value]
  }
}