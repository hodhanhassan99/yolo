# YOLO E-Commerce — Stage 1 Infrastructure Automation

## Overview

YOLO is a full-stack e-commerce application consisting of:

* React frontend
* Node.js / Express backend
* MongoDB database

Stage 1 automates the deployment of the application inside an Ubuntu virtual machine using **Vagrant, Ansible, and Docker**.

The goal is to allow the application to be deployed with minimal manual configuration. Vagrant creates the virtual machine, while Ansible configures the machine, prepares Docker, and deploys the application containers.

---

## Technologies Used

* Ubuntu 22.04 LTS
* Vagrant
* VirtualBox
* Ansible
* Docker
* React
* Node.js
* Express.js
* MongoDB

---

## Application Architecture

The application consists of three Docker containers:

| Container       | Purpose               |  Port |
| --------------- | --------------------- | ----: |
| `app-mongo`     | MongoDB database      | 27017 |
| `yolo-backend`  | Node.js / Express API |  5000 |
| `yolo-frontend` | React frontend        |  3000 |

The containers communicate through the Docker network:

```text
ecommerce-net
```

MongoDB uses a persistent Docker volume:

```text
mongo-data
```

This allows product data to remain available when the MongoDB container is restarted.

---

## Repository Structure

```text
.
├── backend/
├── client/
├── roles/
│   ├── clone-repository/
│   ├── docker-setup/
│   ├── setup-mongodb/
│   ├── backend-deployment/
│   └── frontend-deployment/
├── Vagrantfile
├── playbook.yml
├── hosts
├── ansible.cfg
├── docker-compose.yml
├── README.md
└── explanation.md
```

---

# Prerequisites

The host machine should have the following installed:

* VirtualBox
* Vagrant
* Ansible

Check the installations with:

```bash
vagrant --version
ansible --version
VBoxManage --version
```

---

# Deployment

Clone the repository:

```bash
git clone https://github.com/hodhanhassan99/yolo.git
cd yolo
```

Start and provision the Vagrant virtual machine:

```bash
vagrant up --provision
```

Vagrant creates the Ubuntu virtual machine and automatically runs the Ansible playbook.

The playbook executes the roles sequentially:

```text
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

---

## Ansible Provisioning Process

### 1. Clone Repository

The `clone-repository` role installs Git and clones the application source code into:

```text
/opt/yolo
```

This provides the backend and frontend source code required to build the Docker images.

### 2. Docker Setup

The `docker-setup` role:

* Updates the APT package cache
* Installs Docker
* Installs the Python Docker SDK
* Starts and enables the Docker service
* Creates the `ecommerce-net` Docker network

### 3. MongoDB Deployment

The `setup-mongodb` role creates the MongoDB container.

MongoDB uses the named Docker volume:

```text
mongo-data
```

The volume is mounted at:

```text
/data/db
```

This provides persistent storage for products added through the application.

### 4. Backend Deployment

The `backend-deployment` role builds the backend Docker image from:

```text
/opt/yolo/backend
```

It then starts the backend container and connects it to MongoDB using the configured MongoDB connection string.

The backend API is available on:

```text
http://localhost:5000
```

### 5. Frontend Deployment

The `frontend-deployment` role builds the frontend Docker image from:

```text
/opt/yolo/client
```

It then starts the frontend container and connects it to the Docker network.

The frontend is available at:

```text
http://localhost:3000
```

---

# Testing the Application

After provisioning completes successfully, check that the containers are running:

```bash
vagrant ssh
sudo docker ps
```

The expected containers are:

```text
app-mongo
yolo-backend
yolo-frontend
```

The backend API can also be tested with:

```bash
curl http://localhost:5000/api/products
```

Open the application in a browser:

```text
http://localhost:3000
```

---

# Product Management

The application provides a product-management dashboard that allows users to:

* View products
* Add products
* Update products
* Delete products

Products added through the dashboard are stored in MongoDB.

Because MongoDB uses the `mongo-data` Docker volume, the stored data persists across MongoDB container restarts.

---

# Useful Vagrant Commands

Start the VM:

```bash
vagrant up
```

Provision the VM again:

```bash
vagrant provision
```

SSH into the VM:

```bash
vagrant ssh
```

Check the VM status:

```bash
vagrant status
```

Destroy the VM:

```bash
vagrant destroy -f
```

Recreate and provision the VM:

```bash
vagrant destroy -f
vagrant up --provision
```

---

# Ansible Playbook

The root playbook is:

```text
playbook.yml
```

It executes the following roles:

```yaml
roles:
  - clone-repository
  - docker-setup
  - setup-mongodb
  - backend-deployment
  - frontend-deployment
```

Each role has a separate responsibility. The execution order is important because later roles depend on work performed by earlier roles.

For a detailed explanation of the role order, Ansible modules, and design decisions, see:

```text
explanation.md
```

---

## Author

**Hodhan Hassan**
