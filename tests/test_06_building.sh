#!/usr/bin/env bash
# Test Exercise 6 — Building Images

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

echo ""
echo "${BOLD}Exercise 6 — Building Images${RESET}"
echo ""

# Create Dockerfile
ssh_vm "mkdir -p ~/myapp && echo '<h1>Custom App</h1>' > ~/myapp/index.html && cat > ~/myapp/Dockerfile << 'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF" >/dev/null

# Build image
assert "Docker build succeeds" ssh_vm "cd ~/myapp && docker build -t myapp:v1 ."

images=$(ssh_vm "docker images")
assert_contains "Custom image appears in list" "$images" "myapp.*v1"

# Run custom image
assert "Run custom image" ssh_vm "docker run -d --name myapp -p 9090:80 myapp:v1"
sleep 2

page=$(ssh_vm "curl -s localhost:9090")
assert_contains "Custom image serves correct content" "$page" "Custom App"

# Cleanup
ssh_vm "docker stop myapp && docker rm myapp && docker rmi myapp:v1; rm -rf ~/myapp" >/dev/null 2>&1 || true

report_results "Exercise 6"
