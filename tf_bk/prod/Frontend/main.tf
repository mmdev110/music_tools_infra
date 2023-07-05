terraform {
  backend "s3" {
    bucket = "loopthatloop-terraform-prod"
    key    = "tf/frontend/terraform.tfstate"
  }
}
provider "aws" {
  region = "ap-northeast-1"
}
