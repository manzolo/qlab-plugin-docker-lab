# docker-lab — Docker & Container Management Lab

[![QLab Plugin](https://img.shields.io/badge/QLab-Plugin-blue)](https://github.com/manzolo/qlab)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey)](https://github.com/manzolo/qlab)

A [QLab](https://github.com/manzolo/qlab) plugin that boots a virtual machine with Docker and Docker Compose pre-installed for practicing container management.

## Objectives

- Learn how to run and manage Docker containers
- Build custom Docker images with a Dockerfile
- Use volumes for persistent data and networks for container communication
- Deploy multi-container applications with Docker Compose

## How It Works

1. **Cloud image**: Downloads a minimal Ubuntu 22.04 cloud image (~250MB)
2. **Cloud-init**: Creates `user-data` with Docker and Docker Compose installation
3. **ISO generation**: Packs cloud-init files into a small ISO (cidata)
4. **Overlay disk**: Creates a COW disk on top of the base image (original stays untouched)
5. **QEMU boot**: Starts the VM in background with SSH port forwarding

## Credentials

- **Username:** `labuser`
- **Password:** `labpass`

## Ports

| Service | Host Port | VM Port |
|---------|-----------|---------|
| SSH     | dynamic   | 22      |

> All host ports are dynamically allocated. Use `qlab ports` to see the actual mappings.

## Usage

```bash
# Install the plugin
qlab install docker-lab

# Run the lab
qlab run docker-lab

# Wait ~60s for boot and package installation, then:

# Connect via SSH
qlab shell docker-lab

# Inside the VM, try:
#   - docker run hello-world
#   - docker run -d -p 8080:80 nginx
#   - cd ~/compose-demo && docker-compose up -d

# Stop the VM
qlab stop docker-lab
```

## Exercises

1. **Run your first container**: Execute `docker run hello-world` and understand the output
2. **Run Nginx**: Start an Nginx container with `docker run -d -p 8080:80 nginx` and test with `curl localhost:8080`
3. **Build a custom image**: Create a `Dockerfile`, build with `docker build -t myapp .`, and run it
4. **Use Docker Compose**: Navigate to `~/compose-demo` and run `docker-compose up -d` to start a multi-container app
5. **Explore volumes**: Create a named volume with `docker volume create mydata` and mount it in a container
6. **Docker networks**: Create a custom network with `docker network create mynet` and connect containers to it

## Sample Files

The lab includes a sample Docker Compose project in `~/compose-demo/` with an Nginx web server and MySQL database.

## Resetting

To start fresh, stop and re-run:

```bash
qlab stop docker-lab
qlab run docker-lab
```

Or reset the entire workspace:

```bash
qlab reset
```
