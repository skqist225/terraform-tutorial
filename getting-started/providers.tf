terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.3.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-1"
  alias   = "eu"
}