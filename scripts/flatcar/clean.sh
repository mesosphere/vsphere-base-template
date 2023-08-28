#!/bin/bash

# delete install default ignition file
rm -f /usr/share/oem/config.ign

USER_HOMED_DIR="$(getent passwd "${BASE_IMAGE_SSH_USER}" | cut -d: -f6)"
# clean authorized_keys.d
rm -f "${USER_HOMED_DIR}/.ssh/authorized_keys.d/*"

echo "ensure flatcar first boot"
touch /boot/flatcar/first_boot

# take clanup from ubuntu
echo "remove /var/cache"
find /var/cache -type f -exec rm -rf {} \;

echo "truncate any logs that have built up during the install"
find /var/log -type f -exec truncate --size=0 {} \;

echo "blank netplan machine-id (DUID) so machines get unique ID generated on boot"
truncate -s 0 /etc/machine-id
truncate -s 0 /var/lib/dbus/machine-id  # if not symlinked to "/etc/machine-id"

echo "remove the contents of /tmp and /var/tmp"
rm -rf /tmp/* /var/tmp/*

echo "force a new random seed to be generated"
rm -f /var/lib/systemd/random-seed

echo "clear the history so our install isn't there"
rm -f /root/.wget-hsts
export HISTSIZE=0
