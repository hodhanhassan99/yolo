# YOLO E-Commerce Application — Stage Two

## Overview

Stage Two of this project demonstrates automated deployment of the YOLO full-stack e-commerce application to an AWS EC2 instance using **Terraform and Ansible**.

The application consists of three services:

1. **React frontend** — provides the user interface.
2. **Node.js/Express backend** — provides the API and application logic.
3. **MongoDB** — stores product data.

Unlike a deployment that depends on pre-built Docker images, Stage Two automatically:

* provisions the AWS infrastructure using Terraform;
* creates the required security group;
* generates an Ansible inventory containing the EC2 public IP;
* triggers the Ansible deployment;
* clones the application repository from GitHub;
* creates the Docker network;
* creates the MongoDB container and persistent volume;
* builds the backend Docker image from the cloned source code;
* builds the frontend Docker image from the cloned source code;
* starts all application containers.

This demonstrates the integration of **Infrastructure as Code**, **Configuration Management**, **Git**, and **Docker**.

---

## Technologies Used

* AWS EC2
* Terraform
* Ansible
* Docker
* MongoDB
* Node.js
* React
* Git/GitHub
* Ubuntu Linux

---

## Repository Structure

```text
.
├── playbook.yml
├── hosts
├── roles/
│   ├── docker-setup/
│   ├── setup-mongodb/
│   ├── backend-deployment/
│   └── frontend-deployment/
│
└── Stage_two/
    ├── README.md
    ├── explanation.md
    ├── playbook.yml
    ├── hosts
    ├── roles/
    │   ├── clone-repository/
    │   ├── docker-setup/
    │   ├── setup-mongodb/
    │   ├── backend-deployment/
    │   └── frontend-deployment/
    │
    └── terraform/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── terraform.tfvars
        └── terraform.tfstate
```

The roles in the root `roles/` directory belong to **Stage One**.

The roles inside `Stage_two/roles/` belong to **Stage Two**.

---

# Stage Two Deployment Flow

The deployment follows this sequence:

```text
Terraform
    ↓
AWS EC2 + Security Group
    ↓
Dynamic Ansible Inventory
    ↓
Ansible Playbook
    ↓
clone-repository
    ↓
docker-setup
    ↓
setup-mongodb
    ↓
backend-deployment
    ↓
frontend-deployment
```

Each role is executed in this order because later roles depend on the environment created by earlier roles.

---

# 1. Provision AWS Infrastructure

Navigate to the Terraform directory:

```bash
cd Stage_two/terraform
```

Initialize Terraform:

```bash
terraform init
```

Review the planned infrastructure:

```bash
terraform plan
```

Create the AWS infrastructure:

```bash
terraform apply
```

Terraform provisions the EC2 instance and security group.

The security group allows the ports required by the deployment, including:

* SSH — `22`
* Frontend — `80`
* Backend API — `5000`
* MongoDB — `27017`
* Application port — `3000` where required

Terraform also generates the Ansible inventory dynamically using the EC2 instance's public IP.

---

# 2. Run the Ansible Deployment

After Terraform has provisioned the EC2 instance:

```bash
cd ..
ansible-playbook -i hosts playbook.yml
```

The playbook executes the Stage Two roles in the following order:

```text
clone-repository
docker-setup
setup-mongodb
backend-deployment
frontend-deployment
```

---

# 3. Clone the Application

The `clone-repository` role installs Git and clones the YOLO repository from GitHub.

The repository is cloned into:

```text
/opt/yolo
```

The Stage Two branch is checked out so that the deployment uses the correct version of the project.

This means the deployment does not depend on manually copying the application source code to the EC2 instance.

---

# 4. Configure Docker

The `docker-setup` role installs and configures Docker on the EC2 instance.

It also creates the Docker network required by the application.

The custom network allows the backend and MongoDB containers to communicate using Docker's internal networking.

---

# 5. Deploy MongoDB

The `setup-mongodb` role creates the MongoDB container.

A named Docker volume is used to persist MongoDB data:

```text
mongo-data
```

This means product data is retained when the MongoDB container is restarted or recreated.

---

# 6. Build and Deploy the Backend

The `backend-deployment` role builds the backend Docker image directly from the cloned repository.

The image is built from:

```text
/opt/yolo/backend
```

The role then starts the backend container and connects it to the application Docker network.

The backend receives the MongoDB connection string through an environment variable.

---

# 7. Build and Deploy the Frontend

The `frontend-deployment` role builds the React frontend Docker image directly from:

```text
/opt/yolo/client
```

The resulting image is run inside an Nginx container.

The frontend container is connected to the same Docker network used by the backend and MongoDB.

---

# Application Services

The final deployment contains three main containers:

```text
Frontend
    ↓
Backend API
    ↓
MongoDB
```

The frontend communicates with the backend API, while the backend communicates with MongoDB.

MongoDB data is stored in a persistent Docker volume.

---

# Terraform and Ansible Integration

Terraform and Ansible are integrated so that infrastructure provisioning and application configuration form one automated workflow.

Terraform:

1. Creates the EC2 instance.
2. Creates the security group.
3. Obtains the EC2 public IP.
4. Generates the Ansible inventory.
5. Triggers the Ansible provisioning process.

Ansible then:

1. Installs Git.
2. Clones the application.
3. Installs/configures Docker.
4. Creates the MongoDB service.
5. Builds the backend image.
6. Starts the backend.
7. Builds the frontend image.
8. Starts the frontend.

This removes the need to manually configure the EC2 server after Terraform has created it.

---

# Verification

After deployment, the running containers can be checked with:

```bash
sudo docker ps
```

The frontend can then be accessed through the EC2 instance's public IP address.

The backend can be checked through port `5000`.

MongoDB runs inside Docker and stores its data using the persistent `mongo-data` volume.

---

# Features

* Automated AWS infrastructure provisioning
* Automated EC2 configuration
* GitHub repository cloning
* Docker image building during deployment
* React frontend deployment
* Node.js/Express backend deployment
* MongoDB deployment
* Persistent MongoDB storage
* Docker networking
* Terraform and Ansible integration
* Infrastructure as Code
* Configuration Management

---

## Author

**Hodhan Hassan**
