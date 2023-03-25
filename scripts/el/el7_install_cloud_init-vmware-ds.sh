#!/bin/sh -eux

export REPO_SLUG="https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo"
export GIT_REF="v1.4.1"

DATASOURCE_INSTALL_URL="${REPO_SLUG}/${GIT_REF}/install.sh"

curl -o- ${DATASOURCE_INSTALL_URL} | bash -o errexit -o pipefail
