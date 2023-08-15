resource "aws_instance" "nat" {
  ami                         = data.aws_ami.amazon_linux_2023_arm.id
  instance_type               = "t4g.nano"
  subnet_id                   = data.aws_subnet.public0.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.db_access.name
  user_data                   = file("./user_data.sh")
  source_dest_check           = false
  vpc_security_group_ids = [
    module.nginx_sg.security_group_id,
    module.https_sg.security_group_id,
    module.ssh_sg.security_group_id
  ]
  root_block_device {
    volume_type = "gp3"
    volume_size = 8
  }
  tags = {
    Name = "music_tools_nat_prod"
  }

}
resource "aws_iam_instance_profile" "db_access" {
  name = "music_tools_ec2_prod"
  role = module.ec2_db_access.iam_role_name
}
data "aws_ami" "amazon_linux_2023_arm" {
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
    values = ["arm64"]
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

