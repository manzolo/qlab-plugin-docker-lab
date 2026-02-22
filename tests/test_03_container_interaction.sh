#!/usr/bin/env bash
# Test Exercise 3 — Container Interaction

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

echo ""
echo "${BOLD}Exercise 3 — Container Interaction${RESET}"
echo ""

# Run a container
assert "Run interactive container 'mybox'" ssh_vm "docker run -dit --name mybox ubuntu:22.04 bash"

# Exec into it
os_release=$(ssh_vm "docker exec mybox cat /etc/os-release")
assert_contains "Container runs Ubuntu" "$os_release" "Ubuntu"

# Logs
ssh_vm "docker run -d --name logger ubuntu:22.04 bash -c 'for i in 1 2 3; do echo \"Log \$i\"; sleep 1; done'" >/dev/null
sleep 5
logs=$(ssh_vm "docker logs logger 2>/dev/null")
assert_contains "Container logs are captured" "$logs" "Log"

# Inspect
inspect=$(ssh_vm "docker inspect mybox 2>/dev/null")
assert_contains "Container inspect returns JSON" "$inspect" "\"Id\""

# Copy files
ssh_vm "echo 'test content' > /tmp/testfile.txt && docker cp /tmp/testfile.txt mybox:/tmp/" >/dev/null
copied=$(ssh_vm "docker exec mybox cat /tmp/testfile.txt")
assert_contains "File copied into container" "$copied" "test content"

# Cleanup
ssh_vm "docker stop mybox logger 2>/dev/null; docker rm mybox logger 2>/dev/null; rm -f /tmp/testfile.txt" >/dev/null 2>&1 || true

report_results "Exercise 3"
