#!/bin/sh -eux

echo "installing open-vm-tools"
apt-get install -y open-vm-tools;
mkdir /mnt/hgfs
systemctl enable open-vm-tools
systemctl start open-vm-tools
