variable "name" {}
variable "policy" {}
variable "identifier" {}


//ポリシードキュメント(json)
//何を許可、拒否するのか
data "aws_iam_policy_document" "allow_describe_regions" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeRegions"]
    resources = ["*"]
  }

}
//ポリシードキュメントからIAMポリシー作成
resource "aws_iam_policy" "default" {
  name   = var.name
  policy = var.policy
}
//IAM信頼ポリシー
//IAMロールを何のサービスに関連づけるのか
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = [var.identifier]
    }
  }

}
//IAMロール作成
//信頼ポリシーを指定
resource "aws_iam_role" "default" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

//IAMロールにIAMポリシーを紐付け
resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn

}

output "iam_role_arn" {
  value = aws_iam_role.default.arn
}
output "iam_role_name" {
  value = aws_iam_role.default.name
}
