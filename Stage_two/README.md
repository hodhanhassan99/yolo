# Stage Two AWS Deployment with Terraform and Ansible

## Project Overview

This stage extends the YOLO e-commerce application by deploying it to Amazon Web Services (AWS). The deployment process is fully automated using Terraform for infrastructure provisioning and Ansible for server configuration and application deployment.

The application consists of:

- Frontend (React)
- Backend (Node.js/Express)
- MongoDB Database

All services are deployed as Docker containers on an AWS EC2 Ubuntu instance.

## Technologies Used

-AWS EC2
- Terraform
- Ansible
- Docker
-MongoDB
- React
- Node.js
- Ubuntu 22.04 LTS

## Infrastructure Provisioning

Terraform is used to create:

-EC2 Instance
-Security Group
-Networking configuration

Terraform commands:

terraform init
terraform validate
terraform plan
terraform apply


To destroy the infrastructure use:

terraform destroy


## Configuration Management

Ansible automates the configuration of the EC2 instance.

Tasks performed include these:

-Installing Docker
-Installing Docker Python SDK
-Creating Docker network
-Deploying MongoDB container
-Deploying Backend container
-Deploying Frontend container

Run the deployment using this:

ansible-playbook -i hosts playbook.yml


## Docker Images

The project uses the following Docker images:

MongoDB 6
hodhan/yolo-backend:v1.0.0
hodhan/yolo-frontend:v1.0.1


## Project Structure

Stage_two/
├hosts
├playbook.yml
├terraform/
├roles/
├README.md
└explanation.md


## Deployment Outcome

After deployment:

EC2 instance is created automatically.
Docker is installed automatically.
MongoDB runs inside a container.
Backend runs inside a container.
Frontend runs inside a container.
Users can access the application through the EC2 public IP.

The deployment demonstrates Infrastructure as Code and automated application deployment using Terraform and Ansible.
