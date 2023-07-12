terraform {
  backend "s3" {
    bucket = "music-tools-infra-prod"
    key    = "tf/backend/terraform.tfstate"
  }
}
locals {
  service_name = "music-tools"
  env          = "prod"
}
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      service = local.service_name
      env     = local.env
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us"
  default_tags {
    tags = {
      service = local.service_name
      env     = local.env
    }
  }
}
