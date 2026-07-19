# YOLO E-Commerce Application

This project demonstrates the deployment of a containerized full-stack e-commerce application. The application consists of a React frontend, a Node.js/Express backend, and a MongoDB database, with each component running inside its own Docker container.

The project is divided into two stages:

* **Stage 1:** Automated deployment using Vagrant and Ansible.
* **Stage 2:** Automated infrastructure provisioning using Terraform and server configuration using Ansible on AWS EC2.


## Technologies Used

*Docker
 Docker Compose
 MongoDB
 Node.js
 React
 Vagrant
 Ansible
Terraform
AWS EC2
Ubuntu Server


## Repository Structure

.
├── Stage_two/
├── roles/
├── playbook.yml
├── Vagrantfile
├── hosts
├── README.md
└── explanation.md


---

## Stage 1

Stage 1 deploys the application locally using Vagrant and Ansible.

Start the virtual machine:


vagrant up --provision


Run the Ansible playbook:

ansible-playbook -i hosts playbook.yml


---

## Stage 2

Stage 2 provisions an AWS EC2 instance using Terraform before configuring and deploying the application with Ansible.

Terraform:

cd Stage_two/terraform
terraform init
terraform plan
terraform apply


Ansible:

cd ..
ansible-playbook -i hosts playbook.yml




## Docker Containers

The deployment consists of three containers:

* MongoDB
* Backend API
* Frontend Application

The frontend communicates with the backend API, which stores product data inside MongoDB.



## Features

Product management dashboard
Add products
Persistent MongoDB storage
Automated deployment
Infrastructure as Code
Configuration Management



## Author

Hodhan Hassan
