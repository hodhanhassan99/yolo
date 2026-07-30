terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }

    null = {
      source = "hashicorp/null"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  
}

resource "aws_security_group" "yolo_sg" {
  name        = "yolo-security-group"
  description = "Allow SSH, HTTP and application ports"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "yolo_server" {

  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.yolo_sg.id
  ]

  tags = {
    Name = "YOLO-Server"
  }
}

resource "null_resource" "ansible_provision" {

  depends_on = [
    aws_instance.yolo_server
  ]

  provisioner "local-exec" {
    command = "ansible-playbook -i ../hosts ../playbook.yml"
  }
}