#!/bin/bash
DATACENTER=${DATACENTER:-$PKR_VAR_vsphere_datacenter}
CLUSTER=${CLUSTER:-$PKR_VAR_vsphere_cluster}

VM_NAME="${1}"
VM_FOLDER="${2}"
VM_POOL="${3}"


VMBASEPATH="/${DATACENTER}/vm/${VM_FOLDER}"
VMPATH="${VMBASEPATH%%/}/${VM_NAME}"
POOLPATH="/${DATACENTER}/host/${CLUSTER}/Resources/${VM_POOL}"

# FIXME:  does not work.
if ! govc vm.info "${VMPATH%%/}"; then
    echo "VM ${VMPATH%%/} not found"
    exit 0
fi

esxhost=$(govc vm.info "${VMPATH%%/}" | grep 'Host:' | awk '{print $2}')
if [ "${esxhost}" == "" ]; then
    echo "VM ${VMPATH%%/} not found"
    exit 0
fi

# if VM_POOL is set inject the pool into the command
if [ "${VM_POOL}" != "" ]; then
    ADDOPT="-pool=${POOLPATH}"
fi

# shellcheck disable=SC2086
govc vm.markasvm -host="$esxhost" -dc="${DATACENTER}" $ADDOPT "${VMPATH%%/}"
govc vm.destroy "${VMPATH%%/}"
