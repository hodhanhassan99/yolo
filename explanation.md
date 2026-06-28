#  CAT 2 Project Explanation

## 
The objective of this project was to containerize an existing e-commerce application using Docker. The application consists of three separate components:

1.A React frontend that users interact with.
2.A Node.js/Express backend that processes requests.
3.A MongoDB database that stores product information.


Instead of installing each of these applications directly on my laptop Docker was used to package each one into its own container and Docker Compose was then used to make all three containers communicate with each other automatically.

# the Project Structure

The project was already provided with three main components:

1. **client/** – React frontend
2. **backend/** – Node.js Express API
  3.**MongoDB** – Database


The goal was to create Docker containers that could run all three services together as one application

# Creating the Dockerfiles

I created separate Dockerfiles  for the frontend (client) and backend.

## Frontend Dockerfile

The frontend uses a multistage build.

During the first stage a Node.js image is used to install dependencies and build the React application.

A lightweight Alpine Linux image was selected because it contains only the packages required to build the application, making the final image much smaller.

After the React application was built a second stage copies only the finished production files into an nginx container.

Nginx is used because React production builds consist only of static HTML CSS and JavaScript files Nginx is lightweight fast and designed for serving static websites.

This approach keeps the final frontend image much smaller than keeping Node.js inside the production container.

## Backend Dockerfile

The backend Dockerfile uses the official Node.js Alpine image.


(FROM node:18-alpine)


The backend requires Node.js to execute the Express server.

The Dockerfile copies the application files  installs dependencies using npm and starts the server.


# Creating docker-compose.yml

Docker Compose was used to manage all application containers together.

Three services were defined:

 -frontend

-backend

 -db

Instead of starting each container manually, Docker Compose starts everything using a single command.


(docker compose up)

# Docker Networking

A custom bridge network called **ecommerce-net** was created.
This allows all containers to communicate securely with one another.

Instead of connecting to MongoDB using localhost, the backend connects using the database service name.


(mongodb://db:27017/yolomy)


Docker automatically resolves **db** to the MongoDB container.

#  Port Allocation

Each service exposes only the ports needed by the user.

Frontend-  3000 -> 80


Backend- 5000 -> 5000


MongoDB communicates only inside the Docker network and therefore does not need to expose a port to the host machine.


# Step 6: Database Persistence

One important requirement of the assignment was ensuring that products remain saved even after containers are stopped.

A named Docker volume was created.

volumes:
  mongo-data:


The MongoDB container stores its data inside this volume.

This means that even after running  docker compose down and later  docker compose up
all previously added products remain in the database.

This confirmed that persistence was successfully implemented.

# Problems I Encountered

Several problems were encountered while completing this project.

##  React Build Failure

Initially the frontend image failed to build.

This error appeared: (ERR_OSSL_EVP_UNSUPPORTED)


This happened because the project uses an older version of React Scripts together with a newer version of Node.js.The solution was to update the Dockerfile to use Node.js 18 instead of Node.js 20 which is compatible with the project's version of React Scripts.

## Containers Exiting

At one point all containers stopped running after the application was closed.

Running (docker ps -a) showed that the containers had exited. I restarted the application using (docker compose up) successfully and recreated the running containers.
## Products Did Not Appear Immediately

After adding a product through the form it was successfully saved in MongoDB but it did not immediately appear on the products page.

Initially the page had to be refreshed manually before the product became visible.

The issue was caused because the React state was not updated after the POST request completed.

The solution was to update the application state using the returned product from the backend.


this.setState({
    actualProductList: [...this.state.actualProductList, res.data],
    formVisibleOnPage: false
});


After making this change a newly added products appeared instantly without refreshing the browser.

## Backend Connectivity

At one stage the frontend could not communicate with the backend.

This required checking that:

-the backend container was running,
-the backend was listening on port 5000,   
-Docker Compose networking was correctly configured,
-the MongoDB connection string pointed to the Docker service name instead of localhost.


Once these were corrected, communication between all containers worked successfully.

# Git Workflow

Git was used throughout the project to track changes.

Descriptive commits were made after completing important stages 

Using Git allowed changes to be tracked and previous versions to be restored if necessary.


# Image Versioning

Semantic Versioning (SemVer) was used when tagging Docker images
# Docker Hub

The frontend and backend images were tagged and pushed to Docker Hub.

This allows anyone to clone the repository, pull the images and start the complete application using Docker Compose.

Version tags were used instead of relying only on the latest tag.


This project demonstrated how Docker can simplify application deployment by separating each component into its own container while allowing them to work together through Docker Compose.

The final application successfully

-runs the React frontend
-runs the Express backend
-connects to MongoDB
-persists product data using Docker volumes
-allows products to be added through the web interface
-survives container restarts without losing data


 the project achieved all the required objectives of containerizing a multi-service web application using Docker.