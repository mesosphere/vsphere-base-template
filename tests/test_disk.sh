#!/bin/bash
set -e

## FIXME: Test if the disk was grown
echo "Output df"
df -h

# FIXME: this won't work with nvme devices
# check free space on primary disk
dev=$(df / |tail -1 | cut -d " " -f1 | tr -d '[0-9]')
spaceleft=$(parted ${dev} unit GB print free | grep 'Free Space' | tail -n1 | awk '{print $3}')
echo "${spaceleft%.*} in GB on ${dev}"

test "${spaceleft%.*}" -lt "1" || ( echo "ERROR ${spaceleft%.*}GB free space on root device. Growpart not working" && exit 1 )
