terraform {
  backend "s3" {
    bucket = "music-tools-infra-prod"
    key    = "tf/local/backend/terraform.tfstate"
  }
}
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      service = module.constants.service_name
      env     = module.constants.env
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us"
  default_tags {
    tags = {
      service = module.constants.service_name
      env     = module.constants.env
    }
  }
}
module "constants" {
  source = "./constants"
}
