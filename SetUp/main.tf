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

#Create target machine
resource "aws_instance" "ansible_node" {
  count                       = var.nodeCount
  ami                         = var.amiType
  instance_type               = var.instanceType
  key_name                    = var.pemFile
  associate_public_ip_address = true
  user_data                   = <<-EOF
               #!/bin/bash
               sudo apt update
               sudo apt install -y python3
              EOF
  tags                        = {
    Name = "ANSIBLE TARGET NODE"
  }
}

#Create inventory file
resource "local_file" "ansible_inventory" {
  content = templatefile("./templates/hosts.tpl",
    {
      keyfile     = var.pemFile
      demoservers = aws_instance.ansible_node.*.private_ip
    })
  filename = "./ansible/host.cfg"
}

#Create ansible controller
resource "aws_instance" "ansible_controller" {
  ami                         = var.amiType
  instance_type               = var.instanceType
  key_name                    = var.pemFile
  associate_public_ip_address = true
  user_data                   = <<-EOF
               #!/bin/bash
               sudo apt update
               sudo apt install -y ansible
              EOF
  depends_on                  = [aws_instance.ansible_node]
  tags                        = {
    Name = "ANSIBLE CONTROLLER"
  }
  provisioner "file" {
    source      = "./ansible/host.cfg"
    destination = "/home/ubuntu/host.cfg"
  }
  provisioner "file" {
    source      = "./${var.pemFile}.pem"
    destination = "/home/ubuntu/${var.pemFile}.pem"
  }
  provisioner "remote-exec" {
    inline = ["chmod 400 /home/ubuntu/${var.pemFile}.pem"]
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${var.pemFile}.pem")
    host        = self.public_ip
  }
}