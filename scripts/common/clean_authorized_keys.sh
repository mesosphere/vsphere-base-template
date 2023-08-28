#!/bin/bash -eux
# check for BASE_IMAGE_SSH_USER
test -n "${BASE_IMAGE_SSH_USER}"

# echo "Cleaning authorized_keys for ${BASE_IMAGE_SSH_USER}"
echo "" > "/home/$BASE_IMAGE_SSH_USER/.ssh/authorized_keys"
