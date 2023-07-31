//resource "aws_network_interface" "db_access" {
//  subnet_id   = data.aws_subnet.web0.id
//  attachment {
//    instance     = aws_instance.db_access.id
//    device_index = 1
//  }
//  tags = {
//    Name = "music_tools_db_access_prod"
//  }
//}
resource "aws_instance" "db_access" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.nano"
  subnet_id     = data.aws_subnet.web0.id
  //primary_network_interface_id=aws_network_interface.db_access.id
  iam_instance_profile = aws_iam_instance_profile.db_access.name
  user_data=file("./user_data.sh")
  root_block_device {
    volume_type = "gp3"
    volume_size = 8
  }
  tags = {
    Name = "music_tools_db_access_prod"
  }
}
resource "aws_iam_instance_profile" "db_access" {
  name = "music_tools_ec2_prod"
  role = module.ec2_db_access.iam_role_name
}
data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

module "ec2_db_access" {
  source     = "../../modules/iam_role"
  name       = "music_tools_ec2_role_prod"
  identifier = "ec2.amazonaws.com"
  policy     = data.aws_iam_policy_document.ec2_ssm_agent.json
}
//プリセットがあるのでそれを使用する
data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "ec2_ssm_agent" {
  //既存ポリシーを継承
  source_policy_documents = [data.aws_iam_policy.AmazonSSMManagedInstanceCore.policy]
}

