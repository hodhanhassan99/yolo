# Stage Two — Technical Project Explanation

## 1. Introduction

Stage Two extends the deployment of the YOLO e-commerce application by moving the deployment environment to **AWS EC2**.

Terraform is used for **Infrastructure as Code (IaC)**, while Ansible is used for **configuration management and application deployment**.

The objective is to automate the complete process rather than manually configuring the EC2 server.

The deployment therefore follows this general workflow:

```text
Terraform
    ↓
AWS EC2
    ↓
Dynamic Ansible Inventory
    ↓
Ansible
    ↓
Clone Repository
    ↓
Configure Docker
    ↓
Deploy MongoDB
    ↓
Build Backend
    ↓
Build Frontend
```

---

# 2. Stage Two Playbook

The Stage Two playbook is:

```yaml
---
- name: Deploy YOLO Application on AWS EC2
  hosts: aws
  become: true

  roles:
    - clone-repository
    - docker-setup
    - setup-mongodb
    - backend-deployment
    - frontend-deployment
```

The order of these roles is intentional.

### `clone-repository`

This must happen first because the application source code is required before Docker images can be built.

### `docker-setup`

Docker must be installed and configured before Docker containers or images can be created.

### `setup-mongodb`

MongoDB is started before the backend because the backend requires a database connection.

### `backend-deployment`

The backend image is built from the cloned source code and the backend container is started.

### `frontend-deployment`

The frontend is deployed after the backend so that the complete application stack is available.

---

# 3. Clone Repository Role

The `clone-repository` role was added to ensure that the deployment builds the Docker images from the application's source code instead of depending on pre-built Docker Hub images.

The role contains two tasks.

## Installing Git

```yaml
- name: Install Git
  apt:
    name: git
    state: present
    update_cache: yes
```

The `apt` module is used to install Git on the Ubuntu EC2 instance.

* `name: git` specifies the package.
* `state: present` ensures Git is installed.
* `update_cache: yes` updates the package cache before installation.

## Cloning the repository

```yaml
- name: Clone YOLO repository
  git:
    repo: "{{ repo_url }}"
    dest: "{{ repo_dest }}"
    version: "{{ repo_version }}"
```

The `git` module clones the repository.

The variables are stored in the role's `vars/main.yml`:

```yaml
repo_url: "https://github.com/hodhanhassan99/yolo.git"
repo_dest: "/opt/yolo"
repo_version: "Stage_two"
```

This means Ansible clones the repository into:

```text
/opt/yolo
```

and checks out the Stage Two branch.

This is important because the backend and frontend Dockerfiles are now available on the EC2 instance for the image-building tasks.

---

# 4. Docker Setup Role

The `docker-setup` role prepares the EC2 instance for container deployment.

The role is responsible for installing Docker and creating the Docker network used by the application.

The Docker network provides communication between the containers without requiring the containers to communicate through `localhost`.

The relevant Docker modules are used to manage the Docker environment.

A custom network is used so that the backend can communicate with MongoDB through the Docker network.

---

# 5. MongoDB Role

The `setup-mongodb` role creates the MongoDB container.

MongoDB is connected to the application's Docker network.

A named Docker volume is used for persistence:

```text
mongo-data
```

The purpose of the volume is to prevent product information from being lost when the MongoDB container is restarted or recreated.

The role uses Docker-related Ansible modules such as `docker_container` and `docker_volume`.

The MongoDB service therefore provides both:

* the database required by the backend;
* persistent storage for application data.

---

# 6. Backend Deployment Role

The backend deployment role is responsible for building the backend image and starting the backend container.

The role uses a block:

```yaml
- name: Backend deployment
  block:
```

Using a block groups the related backend tasks together and makes the playbook easier to organize.

## Building the image

```yaml
- name: Build backend Docker image
  docker_image:
    name: "{{ backend_image }}"
    source: build
    build:
      path: "{{ repo_dest }}/backend"
```

The `docker_image` module builds the Docker image.

The important part is:

```yaml
source: build
```

This tells Ansible to build the image instead of pulling a pre-built image.

The build context is:

```text
/opt/yolo/backend
```

which comes from the cloned GitHub repository.

Therefore the deployment is now capable of building the backend image automatically on the EC2 instance.

## Running the backend

```yaml
- name: Run backend container
  docker_container:
    name: "{{ backend_container_name }}"
    image: "{{ backend_image }}"
    state: started
    restart_policy: always
```

The `docker_container` module starts the backend container.

`state: started` ensures that the container is running.

`restart_policy: always` allows Docker to automatically restart the container if it stops.

The backend also receives the MongoDB connection string:

```yaml
env:
  MONGODB_URI: "{{ mongodb_uri }}"
```

This allows the backend application to connect to MongoDB.

The backend is also connected to the configured Docker network.

---

# 7. Frontend Deployment Role

The frontend role follows a similar structure to the backend role.

## Building the frontend image

```yaml
- name: Build frontend Docker image
  docker_image:
    name: "{{ frontend_image }}"
    source: build
    build:
      path: "{{ repo_dest }}/client"
```

The `docker_image` module builds the React application from:

```text
/opt/yolo/client
```

Again, `source: build` is important because it means the image is created during deployment.

The deployment therefore does not depend on a pre-built Docker Hub frontend image.

## Running the frontend

```yaml
- name: Run frontend container
  docker_container:
    name: "{{ frontend_container_name }}"
    image: "{{ frontend_image }}"
    state: started
    restart_policy: always
```

The `docker_container` module starts the frontend container.

The container is connected to the configured Docker network and exposes the frontend port.

---

# 8. Ansible Blocks and Tags

The deployment roles use Ansible blocks to group related operations.

For example:

```yaml
- name: Backend deployment
  block:
    ...
  tags:
    - backend
    - deployment
```

Tags allow individual sections of the deployment to be selected when running Ansible.

For example:

```bash
ansible-playbook -i hosts playbook.yml --tags backend
```

can be used when only the backend deployment tasks need to be executed.

Blocks improve organization by grouping related tasks under one logical operation.

---

# 9. Terraform Infrastructure

Terraform is responsible for creating the AWS infrastructure required by the application.

The main Terraform resources include:

* AWS security group
* AWS EC2 instance
* local Ansible inventory file
* Ansible provisioning trigger

The EC2 instance is associated with the Terraform-created security group.

---

# 10. AWS Security Group

The Terraform security group controls which network traffic can reach the EC2 instance.

The configuration allows required application ports, including:

```text
22     SSH
80     Frontend HTTP
5000   Backend API
27017  MongoDB
3000   Application port where required
```

Port 22 allows SSH access for administration.

Port 80 allows users to access the frontend through a web browser.

Port 5000 allows access to the backend API.

---

# 11. Dynamic Ansible Inventory

Terraform uses the `local_file` resource to generate the Ansible inventory.

The inventory contains the public IP address of the EC2 instance:

```text
[aws]
<EC2_PUBLIC_IP>

[aws:vars]
ansible_user=ubuntu
```

This is preferable to manually entering the IP address because an EC2 instance's public IP can change.

Terraform automatically updates the inventory using the current EC2 public IP.

This creates a connection between the infrastructure provisioning stage and the configuration-management stage.

---

# 12. Terraform and Ansible Integration

Terraform also uses a `null_resource` with a `local-exec` provisioner to trigger Ansible.

This allows the deployment to proceed from infrastructure creation into server configuration.

The overall process becomes:

```text
terraform apply
       ↓
Create EC2
       ↓
Create Security Group
       ↓
Generate hosts file
       ↓
Run Ansible
       ↓
Clone GitHub repository
       ↓
Install/configure Docker
       ↓
Deploy MongoDB
       ↓
Build backend
       ↓
Build frontend
```

This is the main automation feature of Stage Two.

---

# 13. Docker Networking

The application containers use a custom Docker bridge network.

The network allows containers to communicate with each other using their Docker container/service names rather than relying on the EC2 host's localhost address.

The main communication path is:

```text
Frontend
    ↓
Backend
    ↓
MongoDB
```

This separates the services while allowing them to operate together as one application.

---

# 14. MongoDB Persistence

MongoDB uses a named Docker volume.

The volume ensures that database information survives container recreation.

For example, if the MongoDB container is removed and recreated while the named volume remains available, the stored product information is preserved.

This satisfies the persistence requirement of the application.

---

# 15. Verification

The deployment can be verified on the EC2 instance using:

```bash
sudo docker ps
```

The expected result is that the following containers are running:

```text
yolo-frontend
yolo-backend
app-mongo
```

The frontend can then be accessed using the EC2 instance's public IP.

The backend can be checked through its configured API port.

The MongoDB container should remain connected to the application Docker network and use the persistent volume.

---

# 16. Why Stage Two Improves on the Original Deployment

The original approach depended on pre-built Docker images.

Stage Two now improves the deployment process by cloning the source repository and building the images directly on the EC2 server.

The deployment therefore follows:

```text
GitHub source code
       ↓
Clone repository
       ↓
Dockerfile
       ↓
Build image
       ↓
Run container
```

This makes the deployment more automated and reproducible.

A new EC2 instance can be provisioned and configured without manually copying the application source code or manually building the Docker images.

---

# 17. Conclusion

Stage Two demonstrates the integration of several DevOps technologies.

**Terraform** provisions the AWS infrastructure.

**Ansible** configures the EC2 server and deploys the application.

**Git** provides the application source code.

**Docker** packages and runs the application services.

**MongoDB** provides persistent application storage.

The final automated workflow is:

```text
Terraform
    ↓
AWS EC2
    ↓
Dynamic Inventory
    ↓
Ansible
    ↓
Clone Repository
    ↓
Docker Setup
    ↓
MongoDB + Persistent Volume
    ↓
Build Backend Image
    ↓
Run Backend
    ↓
Build Frontend Image
    ↓
Run Frontend
```

This demonstrates Infrastructure as Code, configuration management, containerization, service orchestration, application deployment, and persistent data storage within one automated deployment workflow.
