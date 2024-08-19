#!/bin/sh -eux

# run installing cloud tools again as an active subscription might be needed for install


# determine the major EL version we're runninng
major_version="$(sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}')";

# make sure we use dnf on EL 8+
if [ "$major_version" -ge 8 ]; then
    dnf -y install open-vm-tools cloud-init cloud-utils-growpart
else
    # with el7 we install cloud-init from source
    yum install -y open-vm-tools cloud-init cloud-utils-growpart dracut-modules-growroot https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
fi
