#!/usr/bin/env bash
# docker-lab install script

set -euo pipefail

echo ""
echo "  [docker-lab] Installing..."
echo ""
echo "  This plugin demonstrates how to install and use Docker"
echo "  and Docker Compose inside a QEMU virtual machine."
echo ""
echo "  What you will learn:"
echo "    - How to run and manage Docker containers"
echo "    - How to build Docker images with a Dockerfile"
echo "    - How to use volumes for persistent data"
echo "    - How to create and manage Docker networks"
echo "    - How to deploy multi-container apps with Docker Compose"
echo ""

# Create lab working directory
mkdir -p lab

# Check for required tools
echo "  Checking dependencies..."
local_ok=true
for cmd in qemu-system-x86_64 qemu-img genisoimage curl; do
    if command -v "$cmd" &>/dev/null; then
        echo "    [OK] $cmd"
    else
        echo "    [!!] $cmd — not found (install before running)"
        local_ok=false
    fi
done

if [[ "$local_ok" == true ]]; then
    echo ""
    echo "  All dependencies are available."
else
    echo ""
    echo "  Some dependencies are missing. Install them with:"
    echo "    sudo apt install qemu-kvm qemu-utils genisoimage curl"
fi

echo ""
echo "  [docker-lab] Installation complete."
echo "  Run with: qlab run docker-lab"
