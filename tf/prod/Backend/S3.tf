data "aws_s3_bucket" "alb_log" {
  bucket = module.constants.bucket_name_alb_log
}
data "aws_s3_bucket" "usermedia" {
  bucket = module.constants.bucket_name_usermedia
}