terraform {
  backend "s3" {
    bucket = "music-tools-infra-prod"
    key    = "tf/backend/terraform.tfstate"
  }
}
provider "aws" {
  region = "ap-northeast-1"
}
