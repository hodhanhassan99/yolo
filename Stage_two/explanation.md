Stage Two Deployment Reflection

For Stage Two the main goal was to get our YOLO e-commerce app up and running on AWS. Instead of doing everything by hand in the console, we used Infrastructure as Code (IaC) and some automation tools to make the process smoother. Specifically, I used Terraform to set up the actual cloud infrastructure and Ansible to handle the software installation and get the app deployed. Everything was running on an Ubuntu 22.04 EC2 instance.

Terraform
Terraform was used to handle the heavy lifting for the infrastructure. I used it to define:

    The Ubuntu EC2 instance.

    A security group to manage traffic.

    Firewall rules so that we could access SSH (22), the Frontend (3000), the Backend (5000), and the MongoDB (27017) ports.

It was definitely easier than clicking through the AWS dashboard because I could just write out exactly what I needed. My workflow was basically running terraform init, then validating the code, checking the plan, and finally applying it to spin up the resources.

Ansible
Once Terraform had the server ready, I used Ansible to do all the boring configuration work. I wrote a playbook that took care of:

    Installing Docker and the Python SDK.

    Starting the Docker service and creating a network.

    Pulling all the images and launching the MongoDB, backend, and frontend containers.

This was really helpful because it meant I didn't have to manually SSH in and install everything piece by piece, and it makes the whole deployment repeatable if I need to do it again.

Docker Deployment
I broke the app down into three containers: the database (MongoDB), the backend API, and the frontend. Keeping them separate was a good move because it made it way easier to manage them individually and keeps everything consistent across different environments.

Challenges Encountered
I ran into a few headaches while getting this to work:

    Key Pair: At first, the instance wouldn't launch because the key pair I referenced didn't exist in my AWS account. I had to create a new one and fix the Terraform file.

    Instance Type: I accidentally picked an instance type that wasn't covered by the Free Tier, so I had to switch it over to a t3.micro.

    SSH Issues: I was getting tripped up by the default user—I was trying to log in as ec2-user (which is for Amazon Linux), but since I was using Ubuntu, I had to use the ubuntu username.

    Frontend API calls: The biggest issue was that the frontend was still trying to talk to localhost:5000. I had to go back into the code, change the URL to point to the EC2 public IP, rebuild the image, and redeploy. I also had to clear my browser cache, which took me a minute to realize!

Conclusion
this was a great way to see how Terraform, Ansible, and Docker work together to automate things on AWS. Now the whole setup is automated from building the server to getting the containers running. It definitely shows how much easier DevOps practices make the whole deployment process compared to doing things manually.