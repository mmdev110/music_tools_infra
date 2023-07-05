//CMK
resource "aws_kms_key" "example" {
  description             = "Example CMK"
  enable_key_rotation     = true
  is_enabled              = true
  deletion_window_in_days = 30
}
//エイリアス
//CMKを識別しやすくするためのエイリアス
resource "aws_kms_alias" "example" {
  name          = "alias/example" //をprefixでalias/必ずつける
  target_key_id = aws_kms_key.example.id
}