#!/usr/bin/env bash
# Test Exercise 1 — Docker Anatomy

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

echo ""
echo "${BOLD}Exercise 1 — Docker Anatomy${RESET}"
echo ""

status=$(ssh_vm "systemctl is-active docker")
assert_contains "Docker service is active" "$status" "^active$"

groups_out=$(ssh_vm "groups")
assert_contains "labuser is in docker group" "$groups_out" "docker"

version=$(ssh_vm "docker version 2>/dev/null")
assert_contains "Docker client is available" "$version" "Client"
assert_contains "Docker server is available" "$version" "Server"

info=$(ssh_vm "docker info 2>/dev/null")
assert_contains "Docker info reports storage driver" "$info" "Storage Driver"

ps_out=$(ssh_vm "docker ps 2>/dev/null")
assert_contains "docker ps works" "$ps_out" "CONTAINER ID"

report_results "Exercise 1"
