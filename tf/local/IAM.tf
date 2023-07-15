//ローカル環境にアタッチするIAMユーザー
//IDパスワードはwebからコピペしてくる
resource "aws_iam_user" "backend" {
  name = "music_tools_backend"
}

//ユーザーにアタッチするIAMポリシー
data "aws_iam_policy_document" "backend" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${module.constants.bucket_name_usermedia}/*"]
  }
}

resource "aws_iam_user_policy" "backend" {
  name = "music_tools_backend_policy"
  //path        = "/"
  user        = aws_iam_user.backend.name
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = data.aws_iam_policy_document.backend.json
}

