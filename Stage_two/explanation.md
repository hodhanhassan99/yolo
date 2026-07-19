Stage Two Deployment Reflection
Overview

The primary goal for Stage Two was deploying the YOLO e-commerce application onto AWS using Infrastructure as Code and automation tools to streamline the process instead of manual console configuration I utilized Terraform for cloud infrastructure provisioning and Ansible for software installation and application deployment on an Ubuntu 22.04 EC2 instance
Terraform

Terraform managed infrastructure requirements by defining the Ubuntu EC2 instance alongside a security group for traffic management and firewall rules to permit access to SSH 22 Frontend 3000 Backend 5000 and MongoDB 27017 ports This approach proved superior to dashboard navigation by allowing precise declarations of required resources my workflow involved executing terraform init followed by code validation plan inspection and finally applying the configuration to provision resources
Ansible

Following infrastructure provisioning I used Ansible to automate server configuration through a playbook that installed Docker and the Python SDK started the Docker service created a network and pulled images to launch MongoDB backend and frontend containers This automation eliminated the need for manual SSH configuration and ensures the deployment process is repeatable
Docker Deployment

The application architecture consists of three distinct containers for the database MongoDB the backend API and the frontend Decoupling these components improved management and ensured consistency across different environments
Challenges Encountered

   - Key Pair configuration errors prevented initial instance launches requiring the creation of a new key pair and subsequent Terraform file updates

   - Selecting an instance type outside the Free Tier necessitated a switch to a t3 micro

   - Authentication errors occurred when attempting to use ec2-user instead of the correct ubuntu username for the Ubuntu instance

  -  Frontend API connectivity issues persisted because the code referenced localhost 5000 which required updating the URL to the EC2 public IP rebuilding the image and clearing the browser cache

Conclusion

This project demonstrated the effective integration of Terraform Ansible and Docker to automate AWS deployments from server creation to container execution It highlights how DevOps practices significantly simplify deployment compared to manual methods