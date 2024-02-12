terraform {
  required_providers {
    aws = {
      source  = "hasicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "ap-south-1"
}

#Create Master machine
resource "aws_instance" "ansible_node" {
  count                       = 1
  ami                         = "ami-0ef82eeba2c7a0eeb"
  instance_type               = "t2.micro"
  key_name                    = "linux-pract1"
  associate_public_ip_address = true
  tags                        = {
    Name = "JENKINS MASTER"
  }
}