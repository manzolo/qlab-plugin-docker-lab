# Docker Lab — Step-by-Step Guide

This guide walks you through understanding and using **Docker**, the most popular container platform. Containers package applications with all their dependencies into isolated, portable units that run consistently across any environment.

By the end of this lab you will understand how Docker works, how to manage images and containers, use volumes for persistent data, orchestrate multi-container applications with Docker Compose, and build custom images.

## Prerequisites

Start the lab and wait for the VM to finish booting (~90 seconds):

```bash
qlab run docker-lab
```

Open a terminal and connect to the VM:

```bash
qlab shell docker-lab
```

Make sure cloud-init has finished (Docker installation takes time):

```bash
cloud-init status --wait
```

## Credentials

- **Username:** `labuser`
- **Password:** `labpass`
- **Sudo:** passwordless
- **Docker:** `labuser` is in the `docker` group (no sudo needed for Docker commands)

---

## Exercise 01 — Docker Anatomy

**VM:** docker-lab
**Goal:** Understand how Docker is installed and configured.

Docker uses a client-server architecture. The Docker daemon (`dockerd`) runs in the background and manages containers, images, volumes, and networks. The `docker` CLI is the client that sends commands to the daemon via a Unix socket.

### 1.1 Check Docker is running

```bash
systemctl status docker
```

**Expected output:**
```
● docker.service - Docker Application Container Engine
     Active: active (running) since ...
```

### 1.2 Verify your user can run Docker

```bash
groups
```

**Expected output (includes docker):**
```
labuser adm cdrom sudo dip plugdev docker
```

### 1.3 Docker version

```bash
docker version
```

This shows both client and server versions. Both should be present — if the server is missing, the daemon isn't running.

### 1.4 Docker system info

```bash
docker info 2>/dev/null | head -20
```

Key info: storage driver, number of containers/images, OS, kernel version.

### 1.5 No containers running yet

```bash
docker ps
```

**Expected output:**
```
CONTAINER ID   IMAGE   COMMAND   CREATED   STATUS   PORTS   NAMES
```

Empty table — no containers running yet.

**Verification:** `docker version` shows both Client and Server, and `docker ps` works without sudo.

---

## Exercise 02 — Images and Containers

**VM:** docker-lab
**Goal:** Learn the container lifecycle: pull, run, stop, remove.

Images are read-only templates. Containers are running instances of images. When you `docker run`, Docker creates a writable layer on top of the image — all changes happen in this layer and are lost when the container is removed.

### 2.1 Pull an image

```bash
docker pull nginx:alpine
```

**Expected output:**
```
alpine: Pulling from library/nginx
...
Status: Downloaded newer image for nginx:alpine
```

### 2.2 List images

```bash
docker images
```

**Expected output:**
```
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
nginx        alpine    ...            ...           ~40MB
```

### 2.3 Run a container

```bash
docker run -d --name web -p 8080:80 nginx:alpine
```

Flags:
- `-d` — detached (background)
- `--name web` — name the container "web"
- `-p 8080:80` — map host port 8080 to container port 80

### 2.4 Verify it's running

```bash
docker ps
```

**Expected output:**
```
CONTAINER ID   IMAGE          COMMAND                  ...   PORTS                  NAMES
...            nginx:alpine   "/docker-entrypoint.…"   ...   0.0.0.0:8080->80/tcp   web
```

### 2.5 Access the web server

```bash
curl -s localhost:8080 | head -5
```

You should see the Nginx welcome page HTML.

### 2.6 Stop and remove

```bash
docker stop web
docker rm web
```

### 2.7 Verify cleanup

```bash
docker ps -a | grep web
```

No output — the container is gone.

**Verification:** You can pull images, run containers, access services, and clean up.

---

## Exercise 03 — Container Interaction

**VM:** docker-lab
**Goal:** Learn to interact with running containers.

Containers are not black boxes — you can execute commands inside them, view logs, inspect configuration, and copy files in and out. These skills are essential for debugging containerized applications.

### 3.1 Run a container with a shell

```bash
docker run -dit --name mybox ubuntu:22.04 bash
```

### 3.2 Execute commands inside

```bash
docker exec mybox cat /etc/os-release
```

**Expected output (includes):**
```
NAME="Ubuntu"
VERSION="22.04..."
```

### 3.3 Interactive shell

```bash
docker exec -it mybox bash
```

You're now inside the container. Run `hostname` to see the container ID, then `exit`.

### 3.4 View container logs

```bash
docker run -d --name logger ubuntu:22.04 bash -c 'for i in 1 2 3 4 5; do echo "Log line $i"; sleep 1; done'
sleep 6
docker logs logger
```

**Expected output:**
```
Log line 1
Log line 2
Log line 3
Log line 4
Log line 5
```

### 3.5 Inspect a container

```bash
docker inspect mybox | head -30
```

This returns detailed JSON with network settings, volumes, environment variables, and more.

### 3.6 Copy files

```bash
echo "Hello from host" > /tmp/testfile.txt
docker cp /tmp/testfile.txt mybox:/tmp/
docker exec mybox cat /tmp/testfile.txt
```

**Expected output:**
```
Hello from host
```

### 3.7 Cleanup

```bash
docker stop mybox logger 2>/dev/null; docker rm mybox logger 2>/dev/null
rm -f /tmp/testfile.txt
```

**Verification:** You can exec into containers, view logs, inspect metadata, and copy files.

---

## Exercise 04 — Volumes and Data

**VM:** docker-lab
**Goal:** Understand persistent storage with Docker volumes.

Containers are ephemeral — when removed, their data is lost. Volumes solve this by storing data outside the container's writable layer. Data in volumes persists across container restarts and removals.

### 4.1 Create a named volume

```bash
docker volume create mydata
```

### 4.2 List volumes

```bash
docker volume ls
```

**Expected output:**
```
DRIVER    VOLUME NAME
local     mydata
```

### 4.3 Run a container with the volume

```bash
docker run -d --name vol-test -v mydata:/data ubuntu:22.04 bash -c 'echo "Persistent data" > /data/test.txt && sleep 300'
```

### 4.4 Verify data is written

```bash
docker exec vol-test cat /data/test.txt
```

**Expected output:**
```
Persistent data
```

### 4.5 Remove the container

```bash
docker stop vol-test && docker rm vol-test
```

### 4.6 Data persists in the volume

```bash
docker run --rm -v mydata:/data ubuntu:22.04 cat /data/test.txt
```

**Expected output:**
```
Persistent data
```

The data survived because it's in the volume, not the container.

### 4.7 Bind mount

```bash
mkdir -p /tmp/hostdir
echo "Host file" > /tmp/hostdir/hello.txt
docker run --rm -v /tmp/hostdir:/mnt ubuntu:22.04 cat /mnt/hello.txt
```

**Expected output:**
```
Host file
```

### 4.8 Cleanup

```bash
docker volume rm mydata
rm -rf /tmp/hostdir
```

**Verification:** Data written in a volume persists after the container is removed.

---

## Exercise 05 — Docker Compose

**VM:** docker-lab
**Goal:** Manage containerized services with Docker Compose.

Docker Compose lets you define and manage containers using a YAML file instead of long `docker run` commands. It is the standard way to describe reproducible container setups for development and testing. Even a single-service application benefits from Compose because the configuration is declarative, version-controlled, and easy to share.

### 5.1 Explore the pre-built demo

```bash
ls ~/compose-demo/
```

### 5.2 Read the Compose file

```bash
cat ~/compose-demo/docker-compose.yml
```

This defines a web service running nginx:alpine with a bind-mounted HTML directory, making it easy to serve custom content without rebuilding an image.

### 5.3 Start the stack

```bash
cd ~/compose-demo
docker-compose up -d
```

### 5.4 Check running services

```bash
docker-compose ps
```

The web service should show as "Up".

### 5.5 View logs

```bash
docker-compose logs --tail=5
```

### 5.6 Check individual service

```bash
docker-compose logs web --tail=3
```

### 5.7 Stop and clean up

```bash
docker-compose down
cd ~
```

**Verification:** `docker-compose up -d` starts the service, `docker-compose ps` shows it running.

---

## Exercise 06 — Building Images

**VM:** docker-lab
**Goal:** Create custom Docker images with a Dockerfile.

A Dockerfile is a text file with instructions for building an image. Each instruction creates a layer — Docker caches layers to speed up rebuilds. Understanding layer caching is key to writing efficient Dockerfiles.

### 6.1 Create a project directory

```bash
mkdir -p ~/myapp && cd ~/myapp
```

### 6.2 Write a simple application

```bash
cat > index.html << 'EOF'
<html><body><h1>My Custom App</h1><p>Built with Docker!</p></body></html>
EOF
```

### 6.3 Write a Dockerfile

```bash
cat > Dockerfile << 'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF
```

### 6.4 Build the image

```bash
docker build -t myapp:v1 .
```

**Expected output (last lines):**
```
Successfully built ...
Successfully tagged myapp:v1
```

### 6.5 List custom images

```bash
docker images | grep myapp
```

**Expected output:**
```
myapp   v1   ...   ...   ~40MB
```

### 6.6 Run the custom image

```bash
docker run -d --name myapp -p 9090:80 myapp:v1
curl -s localhost:9090
```

**Expected output:**
```html
<html><body><h1>My Custom App</h1><p>Built with Docker!</p></body></html>
```

### 6.7 Cleanup

```bash
docker stop myapp && docker rm myapp
docker rmi myapp:v1
cd ~ && rm -rf ~/myapp
```

**Verification:** Custom image builds successfully, runs, and serves the expected content.

---

## Troubleshooting

### Docker daemon not running
```bash
sudo systemctl status docker
sudo systemctl start docker
```

### Permission denied
```bash
# Check group membership
groups | grep docker
# If not in docker group:
sudo usermod -aG docker $USER
# Then re-login
```

### Container won't start
```bash
# Check logs for the failed container
docker logs <container_name>
# Check if port is already in use
docker ps | grep <port>
```

### Image pull fails
```bash
# Check internet connectivity
curl -s https://registry-1.docker.io/v2/ | head -1
# Check DNS
cat /etc/resolv.conf
```

### Disk space issues
```bash
# Check Docker disk usage
docker system df
# Clean up unused resources
docker system prune -f
```

### Packages not installed
```bash
cloud-init status --wait
```
