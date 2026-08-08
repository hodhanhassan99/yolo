# Stage 1 — Ansible Deployment Explanation

## 1. Introduction

Stage 1 of the YOLO e-commerce project uses **Vagrant, Ansible, and Docker** to automatically provision and deploy the application inside an Ubuntu virtual machine.

The purpose of using Ansible is to replace manual server configuration and container deployment with a repeatable automation process.

The Ansible playbook executes several roles sequentially. Each role has a specific responsibility, and the order is important because later roles depend on resources configured by earlier roles.

The execution sequence is:

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

# 2. Playbook Structure

The Stage 1 root playbook is `playbook.yml`.

It contains the following roles:

```yaml
---
- hosts: all
  become: true

  roles:
    - clone-repository
    - docker-setup
    - setup-mongodb
    - backend-deployment
    - frontend-deployment
```

The `become: true` option allows Ansible to execute tasks with elevated privileges where required, such as installing packages and managing the Docker service.

Ansible executes roles in the order in which they appear in the playbook. Therefore, the order above is intentional.

---

# 3. Role 1 — clone-repository

## Purpose

The `clone-repository` role prepares the application source code inside the virtual machine.

The assignment requires the deployment process to obtain the application source code automatically rather than requiring the user to manually copy the project into the VM.

The role therefore:

1. Installs Git.
2. Clones the YOLO GitHub repository.
3. Places the repository inside `/opt/yolo`.

The source directory becomes:

```text
/opt/yolo
```

This directory contains the application source code required by the backend and frontend Docker builds.

## Ansible Modules Used

### `apt`

The `apt` module installs Git:

```yaml
- name: Install Git
  apt:
    name: git
    state: present
    update_cache: yes
```

The module ensures that Git is available before attempting to clone the repository.

### `git`

The `git` module retrieves the application source code:

```yaml
- name: Clone YOLO repository
  git:
    repo: "{{ repo_url }}"
    dest: "{{ repo_dest }}"
    version: "{{ repo_version }}"
    force: yes
```

The repository URL, destination, and branch/version are controlled through variables.

## Why This Role Runs First

This role runs first because the frontend and backend images are built from source code.

The source code must therefore exist before the deployment roles attempt to build the Docker images.

---

# 4. Role 2 — docker-setup

## Purpose

The `docker-setup` role prepares the VM to run the application's containers.

The role:

* Updates the package cache.
* Installs Docker.
* Installs the Python Docker SDK required by Ansible's Docker modules.
* Starts and enables the Docker service.
* Creates the application Docker network.

## Ansible Modules Used

### `apt`

The `apt` module is used to install Docker and the Python Docker SDK.

Example:

```yaml
- name: Install Docker
  apt:
    name: "{{ docker_package }}"
    state: present
```

The Python Docker SDK is also installed because Ansible's `docker_container` and `docker_image` modules communicate with Docker through the Docker API.

### `service`

The `service` module starts Docker and enables it to start automatically:

```yaml
- name: Start Docker service
  service:
    name: docker
    state: started
    enabled: yes
```

### `docker_network`

The `docker_network` module creates the shared application network:

```yaml
- name: Create Docker network
  docker_network:
    name: "{{ docker_network }}"
```

The network used by the application is:

```text
ecommerce-net
```

## Why This Role Runs Second

Docker must be installed and running before Ansible can create or manage Docker containers.

The Docker network must also exist before the MongoDB, backend, and frontend containers are started.

Therefore, this role must execute before the container deployment roles.

---

# 5. Role 3 — setup-mongodb

## Purpose

The `setup-mongodb` role creates the MongoDB database container.

MongoDB acts as the persistent data store for the e-commerce application.

The container is configured with:

* A MongoDB Docker image.
* The `ecommerce-net` network.
* Port `27017`.
* A persistent Docker volume.

The MongoDB data directory inside the container is:

```text
/data/db
```

The named Docker volume is:

```text
mongo-data
```

## Ansible Module Used

### `docker_container`

The `docker_container` module creates and starts the MongoDB container.

The role also configures the container's port, volume, network, restart policy, and image.

The important persistence configuration is:

```yaml
volumes:
  - "{{ mongo_volume }}:/data/db"
```

This means MongoDB data is stored in a Docker volume instead of only inside the container's writable layer.

## Why This Role Runs Before the Backend

The backend application needs MongoDB to store and retrieve product information.

The backend is configured with a MongoDB connection string pointing to the MongoDB container:

```text
mongodb://app-mongo:27017/yolomy
```

Therefore, MongoDB is deployed before the backend container.

---

# 6. Role 4 — backend-deployment

## Purpose

The `backend-deployment` role builds and starts the Node.js/Express backend.

Unlike the previous implementation, the application is now built from the source code cloned by the `clone-repository` role.

The backend source code is located at:

```text
/opt/yolo/backend
```

## Ansible Modules Used

### `docker_image`

The `docker_image` module builds the backend Docker image from the application source:

```yaml
- name: Build backend Docker image
  docker_image:
    name: "{{ backend_image }}"
    source: build
    build:
      path: /opt/yolo/backend
```

This means Ansible no longer depends on a pre-built backend image from Docker Hub.

The Docker image is generated during deployment.

### `docker_container`

The `docker_container` module starts the backend container.

It configures:

* Container name
* Backend image
* Port mapping
* MongoDB connection string
* Docker network
* Restart policy

The backend is connected to:

```text
ecommerce-net
```

This allows it to communicate with MongoDB using the MongoDB container name.

## Why This Role Runs Before the Frontend

The frontend communicates with the backend API.

Therefore, the backend must be available before the frontend is deployed.

This ordering also makes the architecture easier to understand:

```text
Frontend → Backend API → MongoDB
```

---

# 7. Role 5 — frontend-deployment

## Purpose

The `frontend-deployment` role builds and starts the React frontend.

The frontend source code is obtained by the `clone-repository` role and is located at:

```text
/opt/yolo/client
```

## Ansible Modules Used

### `docker_image`

The frontend Docker image is built from source:

```yaml
- name: Build frontend Docker image
  docker_image:
    name: "{{ frontend_image }}"
    source: build
    build:
      path: /opt/yolo/client
```

This ensures that the frontend is also built automatically during deployment rather than pulled from Docker Hub.

### `docker_container`

The `docker_container` module starts the frontend container and configures its port and Docker network.

The frontend is exposed on:

```text
3000
```

The container listens on port:

```text
80
```

Therefore the port mapping is:

```text
3000:80
```

---

# 8. Why the Roles Are Ordered Sequentially

The order of the roles is important because each stage prepares something required by the next stage.

### Step 1 — Clone Repository

The source code must exist before Docker images can be built.

```text
GitHub → /opt/yolo
```

### Step 2 — Docker Setup

Docker must be installed before containers or images can be managed.

```text
Docker installation
        ↓
ecommerce-net
```

### Step 3 — MongoDB

The database must be available before the backend is started.

```text
MongoDB
```

### Step 4 — Backend

The backend requires MongoDB and provides the API used by the frontend.

```text
Backend API
```

### Step 5 — Frontend

The frontend is deployed last because it communicates with the backend API.

The resulting architecture is:

```text
┌──────────────────────┐
│   React Frontend     │
│      Port 3000       │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Node.js / Express    │
│      Port 5000       │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│      MongoDB         │
│      Port 27017      │
└──────────────────────┘

All containers communicate through:

ecommerce-net
```

---

# 9. Blocks

The deployment roles use Ansible `block` structures to group related tasks.

For example:

```yaml
- name: Backend deployment
  block:

    - name: Build backend Docker image
      ...

    - name: Run backend container
      ...
```

The block groups all backend-related operations together.

This improves readability and makes it easier to understand which tasks belong to a particular deployment operation.

The same approach is used for the frontend and Docker setup roles.

---

# 10. Tags

Tags are used to make individual sections of the playbook easier to execute selectively.

For example:

```yaml
tags:
  - backend
  - deployment
```

This allows a specific part of the deployment to be targeted when necessary.

For example:

```bash
ansible-playbook -i hosts playbook.yml --tags backend
```

The tags therefore provide flexibility during development and troubleshooting without requiring the entire playbook to be executed every time.

---

# 11. Variables

Variables are used to avoid hard-coding configuration values throughout the roles.

Examples include:

```yaml
backend_container_name: yolo-backend
backend_image: hodhan/yolo-backend:v1.0.0
backend_network: ecommerce-net
backend_port: "5000:5000"
mongodb_uri: mongodb://app-mongo:27017/yolomy
```

Frontend variables include:

```yaml
frontend_container_name: yolo-frontend
frontend_image: hodhan/yolo-frontend:v1.0.5
frontend_network: ecommerce-net
frontend_port: "3000:80"
```

Repository variables define where the source code is obtained and stored.

Using variables makes the deployment easier to maintain because configuration values can be changed without modifying the main task logic.

---

# 12. Docker Networking

The application containers are connected to the same Docker network:

```text
ecommerce-net
```

This allows the containers to communicate with each other using Docker's internal networking and container names.

For example, the backend connects to MongoDB using:

```text
mongodb://app-mongo:27017/yolomy
```

The backend does not need to connect to MongoDB using `localhost` because `localhost` inside the backend container refers to the backend container itself.

The shared Docker network therefore allows:

```text
yolo-frontend
      ↓
yolo-backend
      ↓
app-mongo
```

---

# 13. MongoDB Persistence

MongoDB uses the named Docker volume:

```text
mongo-data
```

The volume is mounted to:

```text
/data/db
```

This is important because Docker containers themselves are replaceable.

Without a persistent volume, deleting or recreating the MongoDB container could result in the loss of stored products.

With the named volume, the database data remains available when the MongoDB container is restarted or recreated while the volume is preserved.

This allows products added through the dashboard to persist.

---

# 14. Verification

After running:

```bash
vagrant up --provision
```

the deployment should complete without Ansible failures.

The containers can be verified with:

```bash
vagrant ssh
sudo docker ps
```

The expected services are:

```text
app-mongo
yolo-backend
yolo-frontend
```

The backend API can be tested with:

```bash
curl http://localhost:5000/api/products
```

The frontend can be accessed through:

```text
http://localhost:3000
```

A product can then be added through the dashboard.

The product should be stored in MongoDB and remain available after the MongoDB container is restarted because of the `mongo-data` persistent volume.

---

# 15. Conclusion

The Stage 1 implementation demonstrates configuration management through Ansible and virtualization through Vagrant.

The deployment is divided into separate roles so that each part of the infrastructure has a clear responsibility:

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

This structure makes the deployment repeatable and reduces the amount of manual configuration required.

The combination of Ansible roles, variables, blocks, tags, Docker networking, source-based image builds, and persistent MongoDB storage provides a reproducible deployment process for the YOLO e-commerce application.
