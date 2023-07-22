data "aws_ses_domain_identity" "email" {
  domain = module.constants.email_domain
}