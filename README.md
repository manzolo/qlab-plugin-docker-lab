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

> **New to Docker?** See the [Step-by-Step Guide](guide.md) for complete walkthroughs with full examples.

| # | Exercise | What you'll do |
|---|----------|----------------|
| 1 | **Docker Anatomy** | Explore Docker installation, daemon, and basic commands |
| 2 | **Images and Containers** | Pull images, run containers, manage lifecycle |
| 3 | **Container Interaction** | Execute commands, inspect logs, attach to containers |
| 4 | **Volumes and Data** | Create volumes, bind mounts, persist data |
| 5 | **Docker Compose** | Deploy multi-container apps with `~/compose-demo` |
| 6 | **Building Images** | Write Dockerfiles and build custom images |

## Automated Tests

An automated test suite validates the exercises against a running VM:

```bash
# Start the lab first
qlab run docker-lab
# Wait ~60s for cloud-init, then run all tests
qlab test docker-lab
```

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
