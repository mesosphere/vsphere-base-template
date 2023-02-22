
include mkinclude/packer.mk
include mkinclude/govc.mk


VSPHERE_FOLDER ?= "build-d2iq-base-templates" 

NAME_POSTFIX ?= -manual-build-$(shell whoami)

manifests/di2q-base-%$(NAME_POSTFIX).json: packer.initialized
	$(PACKER) build -var vsphere_folder=$(VSPHERE_FOLDER) -var-file=./images/base-$*.pkrvar.hcl vsphere.pkr.hcl

ubuntu: manifests/di2q-base-Ubuntu-20.04$(NAME_POSTFIX).json manifests/di2q-build-Ubuntu-20$(NAME_POSTFIX).json
rocky: manifests/di2q-base-RockyLinux-8.7$(NAME_POSTFIX).json manifests/di2q-base-RockyLinux-9.1$(NAME_POSTFIX).json
centos: manifests/di2q-base-CentOS-7.9$(NAME_POSTFIX).json
