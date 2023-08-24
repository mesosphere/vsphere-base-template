#!/bin/bash -eux

DATACENTER=${DATACENTER:-$PKR_VAR_vsphere_datacenter}
DATASTORE=${DATASTORE:-$PKR_VAR_vsphere_datastore}
VM_FOLDER=${VM_FOLDER:-$PKR_VAR_vsphere_folder}
RESOURCE_POOL=${RESOURCE_POOL:-$PKR_VAR_vsphere_resource_pool}

FLATCAR_LTS_VERSION=${FLATCAR_LTS_VERSION:-"lts"}

VM_NAME=d2iq-base-Flatcar-${FLATCAR_LTS_VERSION}

wget -O "${VM_NAME}.ova" -nv https://lts.release.flatcar-linux.net/amd64-usr/${FLATCAR_LTS_VERSION}/flatcar_production_vmware_ova.ova

${GOVC} import.ova -dc="${DATACENTER}" -ds="${DATASTORE}" -folder="${VM_FOLDER}" -pool="${RESOURCE_POOL}"  -name="${VM_NAME}" "${VM_NAME}.ova"

${GOVC} snapshot.create -vm "${VM_NAME}" snapshot_1
${GOVC} vm.markastemplate "${VM_NAME}"
