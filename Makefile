
include mkinclude/packer.mk
include mkinclude/govc.mk


VSPHERE_FOLDER ?= build-d2iq-base-templates
RELEASE_FOLDER ?= d2iq-base-templates
NAME_POSTFIX ?= -manual-build-$(shell whoami)

manifests/d2iq-base-%$(NAME_POSTFIX).json: packer.initialized $(GOVC)
	$(PACKER) build -force -var vsphere_folder=$(VSPHERE_FOLDER) -var vm_name=$(shell basename -s .json $@) -var vm_name_prefix="" -var vm_name_postfix=""   -var-file=./images/base-$*.pkrvar.hcl -var manifest_output=$@ vsphere.pkr.hcl

manifests/tests/d2iq-base-%$(NAME_POSTFIX).json: manifests/d2iq-base-%$(NAME_POSTFIX).json
	$(PACKER) build -force -var vsphere_folder=$(VSPHERE_FOLDER) -var vm_name=test-$(shell basename -s .json $<) -var template_manifest=$< -var manifest_output=$@ clone-test.pkr.hcl
	bash -x mkinclude/helper_deletetemplate.sh $(shell jq -r '.builds[0].custom_data.template_name' $<)
	govc vm.destroy /$(shell jq -r '.builds[0].custom_data.datacenter' $<)/vm/$(VSPHERE_FOLDER)/test-$(shell basename -s .json $<)

.PHONY: release/d2iq-base-%$(NAME_POSTFIX)
release/d2iq-base-%$(NAME_POSTFIX): manifests/d2iq-base-%$(NAME_POSTFIX).json
	bash -x mkinclude/helper_deletetemplate.sh $(RELEASE_FOLDER)/d2iq-base-$* || true
	govc object.rename /$(shell jq -r '.builds[0].custom_data.datacenter' $<)/vm/$(shell jq -r '.builds[0].custom_data.template_name' $<) d2iq-base-$*
	govc object.mv /$(shell jq -r '.builds[0].custom_data.datacenter' $<)/vm/$(VSPHERE_FOLDER)/d2iq-base-$* /$(shell jq -r '.builds[0].custom_data.datacenter' $<)/vm/$(RELEASE_FOLDER)

ubuntu: manifests/d2iq-base-Ubuntu-20.04$(NAME_POSTFIX).json manifests/d2iq-base-Ubuntu-22.04$(NAME_POSTFIX).json
ubuntu-test: manifests/test/d2iq-base-Ubuntu-20.04$(NAME_POSTFIX).json manifests/test/d2iq-base-Ubuntu-22.04$(NAME_POSTFIX).json
ubuntu-release: release/d2iq-base-Ubuntu-20.04$(NAME_POSTFIX) release/d2iq-base-Ubuntu-22.04$(NAME_POSTFIX)

rocky: manifests/d2iq-base-RockyLinux-8.7$(NAME_POSTFIX).json manifests/d2iq-base-RockyLinux-9.1$(NAME_POSTFIX).json
rocky-test: manifests/tests/d2iq-base-RockyLinux-8.7$(NAME_POSTFIX).json manifests/tests/d2iq-base-RockyLinux-9.1$(NAME_POSTFIX).json
rocky-release: release/d2iq-base-RockyLinux-8.7$(NAME_POSTFIX) release/d2iq-base-RockyLinux-9.1$(NAME_POSTFIX)

centos: manifests/d2iq-base-CentOS-7.9$(NAME_POSTFIX).json
centos-test: manifests/tests/d2iq-base-CentOS-7.9$(NAME_POSTFIX).json
centos-release: release/d2iq-base-CentOS-7.9$(NAME_POSTFIX)

