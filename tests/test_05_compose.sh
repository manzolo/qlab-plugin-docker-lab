#!/usr/bin/env bash
# Test Exercise 5 — Docker Compose

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

echo ""
echo "${BOLD}Exercise 5 — Docker Compose${RESET}"
echo ""

# Compose demo directory exists
assert "compose-demo directory exists" ssh_vm "test -d ~/compose-demo"

# docker-compose.yml exists
assert "docker-compose.yml exists" ssh_vm "test -f ~/compose-demo/docker-compose.yml"

# docker-compose is available
assert "docker-compose is installed" ssh_vm "which docker-compose || docker compose version"

# Create a lightweight compose file for testing (avoids disk space issues)
ssh_vm "mkdir -p ~/compose-test/html && echo '<h1>Compose</h1>' > ~/compose-test/html/index.html"
ssh_vm "cat > ~/compose-test/docker-compose.yml << 'EOF'
version: '3'
services:
  web:
    image: nginx:alpine
    ports:
      - \"9090:80\"
    volumes:
      - ./html:/usr/share/nginx/html
EOF"

# Start the stack
assert "docker-compose up succeeds" ssh_vm "cd ~/compose-test && docker compose up -d 2>&1 || docker-compose up -d 2>&1"
sleep 5

# Check services are running
ps_out=$(ssh_vm "cd ~/compose-test && docker compose ps 2>/dev/null || docker-compose ps 2>/dev/null")
assert_contains "Compose shows running services" "$ps_out" "Up|running"

# View logs
assert "docker-compose logs works" ssh_vm "cd ~/compose-test && docker compose logs --tail=3 2>/dev/null || docker-compose logs --tail=3 2>/dev/null"

# Stop the stack
assert "docker-compose down succeeds" ssh_vm "cd ~/compose-test && docker compose down 2>/dev/null || docker-compose down 2>/dev/null"

# Cleanup
ssh_vm "rm -rf ~/compose-test" >/dev/null 2>&1 || true

report_results "Exercise 5"
