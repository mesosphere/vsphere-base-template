#!/bin/bash
set -e

echo "User login succeeded"

echo "Test if this is executed in uid 0"
test "$(id -u)" -eq 0
