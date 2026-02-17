#!/bin/bash
# Set hostname from guestinfo.metadata for CAPV
set -euo pipefail

# Get metadata if it exists
if ! metadata=$(vmware-rpctool 'info-get guestinfo.metadata' 2>/dev/null); then
  exit 0
fi

# Decode if base64
encoding=$(vmware-rpctool 'info-get guestinfo.metadata.encoding' 2>/dev/null || echo "")
if [ "$encoding" = "base64" ]; then
  metadata=$(echo "$metadata" | base64 -d)
fi

# Extract hostname (CAPV uses "local-hostname")
hostname=$(echo "$metadata" | awk '/^local-hostname:|^  local-hostname:/{gsub("^[ \t]*(local-)?hostname:[ \t]*",""); gsub("\"",""); print; exit}')
if [ -n "$hostname" ]; then
  echo "$hostname" > /etc/hostname
  hostnamectl set-hostname "$hostname" 2>/dev/null || true
  
  # Also populate coreos metadata file for compatibility
  mkdir -p /run/metadata
  echo "COREOS_CUSTOM_HOSTNAME=${hostname}" >> /run/metadata/coreos
fi
