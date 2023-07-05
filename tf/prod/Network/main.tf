terraform {
  backend "s3" {
    bucket = "loopthatloop-terraform-prod"
    key    = "tf/network/terraform.tfstate"
  }
}
provider "aws" {
  region = "ap-northeast-1"
}
