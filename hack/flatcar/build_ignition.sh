#!/bin/bash
set -e
cat <<EOF >/tmp/clc.yaml
passwd:
  users:
    - name: core
      ssh_authorized_keys:
        - "\${public_key}"
systemd:
  units:
  - name: docker.service
    enable: true
  # Mask update-engine and locksmithd to disable automatic updates during image creation.
  - name: update-engine.service
    mask: true
  - name: locksmithd.service
    mask: true
EOF

CT_VER=v0.9.3

# Specify Architecture
# ARCH=aarch64 # ARM's 64-bit architecture
ARCH=x86_64

# Specify OS
# OS=apple-darwin # MacOS
# OS=pc-windows-gnu.exe # Windows
OS=unknown-linux-gnu # Linux
if [[ `uname -s` == "Darwin" ]]; then
OS=apple-darwin
fi

# Specify download URL
DOWNLOAD_URL=https://github.com/flatcar/container-linux-config-transpiler/releases/download
CT_BIN="/tmp/ct-${CT_VER}-${ARCH}-${OS}"

# Remove previous downloads
rm -f "${CT_BIN}" "${CT_BIN}.asc" /tmp/coreos-app-signing-pubkey.gpg

# Download Config Transpiler binary
curl -L ${DOWNLOAD_URL}/${CT_VER}/ct-${CT_VER}-${ARCH}-${OS} -o "${CT_BIN}"
chmod u+x ${CT_BIN}

${CT_BIN} < /tmp/clc.yaml | jq '.' | tee /tmp/ignition.json
