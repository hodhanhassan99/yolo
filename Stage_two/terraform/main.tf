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

    local = {
      source = "hashicorp/local"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "yolo_sg" {
  name        = "yolo-security-group"
  description = "Allow SSH, HTTP and application ports"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Frontend"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Backend API"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MongoDB"
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

  tags = {
    Name = "yolo-security-group"
  }
}

resource "aws_instance" "yolo_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.yolo_sg.id]

  tags = {
    Name = "YOLO-Server"
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../hosts"

  content = <<EOF
[aws]
${aws_instance.yolo_server.public_ip}

[aws:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/hodhanhassan/.ssh/new-yolo-key.pem
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
}

resource "null_resource" "ansible_provision" {

  depends_on = [
    aws_instance.yolo_server,
    local_file.ansible_inventory
  ]

  provisioner "local-exec" {
    working_dir = "${path.module}/.."
    command     = "ansible-playbook -i hosts playbook.yml"
  }
}