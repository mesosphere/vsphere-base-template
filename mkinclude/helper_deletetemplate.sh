#!/bin/bash
DATACENTER=${DATACENTER:-$PKR_VAR_vsphere_datacenter}

VM_NAME="${1}"
VM_FOLDER="${2}"


VMBASEPATH="/${DATACENTER}/vm/${VM_FOLDER}"
VMPATH="${VMBASEPATH%%/}/${VM_NAME}"

# FIXME:  does not work.
if ! govc vm.info ${VMPATH%%/}; then
    echo "VM ${VMPATH%%/} not found"
    exit 0
fi

esxhost=$(govc vm.info ${VMPATH%%/} | grep 'Host:' | awk '{print $2}')
if [ "${esxhost}" == "" ]; then
    echo "VM ${VMPATH%%/} not found"
    exit 0
fi

govc vm.markasvm -host=$esxhost -dc=${DATACENTER} ${VMPATH%%/}
govc vm.destroy ${VMPATH%%/}
