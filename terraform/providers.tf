# AWS Provider
provider "aws" {
  region = "eu-west-2"
}

/*
terraform {
  backend "s3" {
    bucket         = "talend-dev-bucket-np"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}*/
