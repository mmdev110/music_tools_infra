//MediaConvertはterraform未対応
//ジョブテンプレート名
locals {
  mediaconvert_job_template_name = "music_tools_convert_local"
  mediaconvert_region            = "ap-northeast-1"
}
//エンドポイント
data "aws_ssm_parameter" "mediaconvert_endpoint" {
  name = "/music-tools/local/backend/mediaconvert_endpoint"
}

//実行時のIAMロール
module "mediaconvert_role" {
  source     = "../modules/iam_role"
  name       = "mediaconvert_role"
  identifier = "mediaconvert.amazonaws.com"
  policy     = data.aws_iam_policy_document.mediaconvert.json
}
data "aws_iam_policy" "AmazonS3FullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
data "aws_iam_policy" "AmazonAPIGatewayInvokeFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}

data "aws_iam_policy_document" "mediaconvert" {
  //MediaConvert_Default_Roleの内容を継承
  source_policy_documents = [
    data.aws_iam_policy.AmazonS3FullAccess.policy,
    data.aws_iam_policy.AmazonAPIGatewayInvokeFullAccess.policy,
  ]

  //statement {
  //  effect    = "Allow"
  //  actions   = ["ssm:GetParameters", "kms:Decrypt", "s3:GetObject", "s3:GetBucketLocation"]
  //  resources = ["*"]
  //}
}