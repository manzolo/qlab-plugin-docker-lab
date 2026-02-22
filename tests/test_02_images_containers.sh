#!/usr/bin/env bash
# Test Exercise 2 — Images and Containers

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

echo ""
echo "${BOLD}Exercise 2 — Images and Containers${RESET}"
echo ""

# Pull an image
assert "Pull nginx:alpine" ssh_vm "docker pull nginx:alpine"

images=$(ssh_vm "docker images")
assert_contains "nginx:alpine appears in images list" "$images" "nginx.*alpine"

# Run a container
assert "Run container 'web' on port 8080" ssh_vm "docker run -d --name web -p 8080:80 nginx:alpine"

ps_out=$(ssh_vm "docker ps")
assert_contains "Container 'web' is running" "$ps_out" "web"

# Access the service
sleep 2
page=$(ssh_vm "curl -s localhost:8080")
assert_contains "Web server responds" "$page" "<"

# Stop and remove
assert "Stop container" ssh_vm "docker stop web"
assert "Remove container" ssh_vm "docker rm web"

ps_all=$(ssh_vm "docker ps -a")
assert_not_contains "Container is removed" "$ps_all" " web$"

# Cleanup
ssh_vm "docker rmi nginx:alpine 2>/dev/null" || true

report_results "Exercise 2"
