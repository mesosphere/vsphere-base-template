# D2iQ vSphere Base Images

*Disclaimer: this project is being used providing internal base images for vSphere. These are not meant for production use.*

Please refer to github.com/mesosphere/konvoy-image-builder/ for DKP images

## Prerequisites

- the tooling expects [jq](https://stedolan.github.io/jq/download/) to be installed
- ensure `make`, `wget` and `unzip
- ensure to have `mkiso` on the system running this
- For vsphere connection `VSPHERE_SERVER` `VSPHERE_USER` and `VSPHERE_PASSWORD` environment variables must be set
- also `GOVC_URL` must be set. This can be achieved by `export GOVC_URL="${VSPHERE_USER}:${VSPHERE_PASSWORD}@${VSPHERE_SERVER}"`

Following variables must be set according to structure of the vSphere setup:

- `PKR_VAR_vsphere_datacenter`: name of the vsphere datacenter to be used
- `PKR_VAR_vsphere_cluster`: name of the vsphere cluster to be used
- `PKR_VAR_vsphere_datastore`: the datastore templates and vms are placed on
- `PKR_VAR_vsphere_network`: a vSphere network which can be reached from the machine running the build ( SSH ports needed )

### RHEL

For Red Hat Enterprise Linux builds you need to set

- RHN_USERNAME - as the subscription manager username
- RHN_PASSWORD - as the subscription manager password

or using [Activation Keys](https://access.redhat.com/management/activation_keys)

- RHN_SUBSCRIPTION_KEY - as the activation key name
- RHN_SUBSCRIPTION_ORG - as the activation organisation

To be able to install RHEL you would need to provide an ISO to the vSphere cluster. Download the ISO using your RHN account and upload it to an vSphere datastore.

`PKR_VAR_iso_path_entry="[your-data-store-name] path/to/rhel-server-7.9-x86_64-dvd.iso"` tells packer where to get the ISO from

## Build

There are distribution based make targets for building images

- `make ubuntu` - Ubuntu 20.04 and 22.04
- `make rocky` - Ubuntu 8 and 9
- `make centos` - Centos 7.9
- `make rhel` - RHEL 7.9, 8.4, and 8.6

Templates and VMs are created by default in the folder `build-d2iq-base-templates` This can be changed by injecting the environment variable `VSPHERE_FOLDER`

vm and template names are generated with this schema `d2iq-base-<Distro>-<Version>${NAME_POSTFIX}` while NAME_POSTFIX is by default `-manual-build-$(shell whoami)` to support local builds. The postfix can be changed by injecting the environment variable `NAME_POSTFIX`

## Test

Like build tests can be executed by distribution. For exmaple `make ubuntu-test`. This will build a template using build steps and afterwards start a new build using the clone method using the previously generated template.

This packer build will execute scripts in ./tests. Whenever the do not exit 0 an error is thrown.

After successfully testing a template the test vm and its template are being deleted.

## Release

The release target for each distribution e.g. `ubuntu-release` will run a normal build process and then rename the instance to delete its build postfix. After renaming the template will be moved from the build folder (`VSPHERE_FOLDER`) into `RELEASE_FOLDER` which is by default `d2iq-base-templates`
