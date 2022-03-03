terraform {
  #   cloud {
  #     organization = "skqist225"

  #     workspaces {
  #       name = "provisioners"
  #     }
  #   }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.3.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDDWV2cOTfPGglg9Msny4gJIQusw6FKMpXrPvRb7Nb9gCa4ph6gAPSY49Jjfsd5wo+On9q1SX2Q3hV19mC2lz9KIo5X7ODRqueUwDs6hj4v5k2bQs4ERzG10+lPEHP41n4j/6Ri2CXienwcVSeqXVigZrdPKbY3rkKIYWxynZtWVJ+E7SX5w3jOClFhikY0IIL84xnntL2ZTc2Qiio2fHH5w9QLPPe8Pc8xM8CKNvTgczjzYq+F29TzQKDt/TkxozJAwzosmFPqOKO8Dugw0sONoFm7TVQFTHoLGrXLjX8BVbep0T7it5kaeCZwx6WqmjE50WFVLN4vT7vlDN9h04w2/3De7WDOFBMnFBzcEIC5nyMYoOjVoSrE+N3bzvSYvlNmP/r8cZjjhAiNURnOCuhXz+6FEzPLxZAzi6Lcy9EzUbasvpEEeZoe0/dGGrD5kuN0iZYZ+V8HeiqwgdNp7EMh0QS3jrraZv1Da/meHKNFBZYBQ479AazyCygXRixdtbk= skqist225@DESKTOP-TSOPMRN"
}



data "aws_vpc" "main" {
  id = "vpc-018ea4034e483d6f7"
}



data "template_file" "user_data" {
  template = file("./userdata.yaml")
}

data "template_file" "private_key" {
  template = file("~/.ssh/terraform")
}

resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "My Server Security Group"
  vpc_id      = data.aws_vpc.main.id

  ingress = [{
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    },
    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["123.21.254.35/32"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }

  ]

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_instance" "my_server" {
  ami                    = "ami-0db78d64e83cf051e"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.sg_my_server.id]
  user_data              = data.template_file.user_data.rendered
  #     provisioner "local-exec" {
  #     command = "echo ${self.private_ip} >> private_ips.txt"
  #   }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = data.template_file.private_key
      host        = self.public_ip
    }


    inline = [
      "echo ${self.private_ip} >> private_ips.txt",
    ]


  }


  tags = {
    Name = "MyServer"
  }
}

output "public_ip" {
  value = aws_instance.my_server.public_ip
}