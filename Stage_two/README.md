Stage Two AWS Deployment via Terraform and Ansible
Summary

This phase involves migrating the YOLO e-commerce application to Amazon Web Services utilizing full automation for infrastructure and deployment tasks Terraform handles provisioning while Ansible manages server setup and application orchestration
Architecture

The application runs on an Ubuntu 22 04 LTS EC2 instance and utilizes a three-container Docker architecture comprising a React frontend a Node js backend and a MongoDB database
Technology Stack

    Infrastructure AWS EC2 and Terraform

    Automation Ansible

    Containerization Docker

    Application React and Node js

    Database MongoDB 6

Infrastructure Provisioning

Terraform defines the EC2 instance networking and security group rules to ensure a reproducible environment
Workflow Commands

    Initialization terraform init

    Validation terraform validate

    Planning terraform plan

    Deployment terraform apply

    Teardown terraform destroy

Configuration Management

Ansible streamlines the server setup by executing a playbook that installs Docker and the necessary Python SDKs creates a dedicated network and deploys the containerized services
Execution Command

ansible-playbook -i hosts playbook.yml
Application Components

    Database MongoDB 6

    Backend hodhan/yolo-backend:v1.0.0

    Frontend hodhan/yolo-frontend:v1.0.1

Project Directory

Stage_two/
├hosts
├playbook.yml
├terraform/
├roles/
├README.md
└explanation.md

Deployment Results

The automated pipeline successfully provisions the EC2 infrastructure and configures the environment to host the three-tier application stack Upon completion the application becomes accessible via the EC2 public IP showcasing the efficiency of combining Infrastructure as Code with automated configuration management