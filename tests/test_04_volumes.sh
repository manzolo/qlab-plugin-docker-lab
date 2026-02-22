#!/usr/bin/env bash
# Test Exercise 4 — Volumes and Data

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

echo ""
echo "${BOLD}Exercise 4 — Volumes and Data${RESET}"
echo ""

# Create volume
assert "Create named volume" ssh_vm "docker volume create mydata"

volumes=$(ssh_vm "docker volume ls")
assert_contains "Volume appears in list" "$volumes" "mydata"

# Write data via container
ssh_vm "docker run --rm -v mydata:/data ubuntu:22.04 bash -c 'echo persistent > /data/test.txt'" >/dev/null
data=$(ssh_vm "docker run --rm -v mydata:/data ubuntu:22.04 cat /data/test.txt")
assert_contains "Data persists across containers" "$data" "persistent"

# Bind mount
ssh_vm "mkdir -p /tmp/hostdir && echo 'hostdata' > /tmp/hostdir/file.txt" >/dev/null
bind_data=$(ssh_vm "docker run --rm -v /tmp/hostdir:/mnt ubuntu:22.04 cat /mnt/file.txt")
assert_contains "Bind mount works" "$bind_data" "hostdata"

# Cleanup
ssh_vm "docker volume rm mydata 2>/dev/null; rm -rf /tmp/hostdir" >/dev/null 2>&1 || true

report_results "Exercise 4"
