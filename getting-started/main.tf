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

variable "instance_type" {
    type = string
}

locals {
  project_name = "Andrew"
}

resource "aws_instance" "my_server" {
  ami           = "ami-0db78d64e83cf051e"
  instance_type = var.instance_type

  tags = {
    Name = "MyServer-${local.project_name}"
  }
}

output "instance_ip_address" {
  value = aws_instance.my_server.public_ip
}