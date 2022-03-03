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

