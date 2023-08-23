
include mkinclude/packer.mk
include mkinclude/govc.mk


VSPHERE_FOLDER ?= build-d2iq-base-templates
RELEASE_FOLDER ?= d2iq-base-templates
NAME_POSTFIX ?= -manual-build-$(shell whoami)

PACKER_ON_ERROR ?= cleanup

manifests/d2iq-base-%$(NAME_POSTFIX).json: packer.initialized vsphere.pkr.hcl $(GOVC)
	$(PACKER) build -force -var vsphere_folder=$(VSPHERE_FOLDER) -var vm_name=$(shell basename -s .json $@) -var vm_name_prefix="" -var vm_name_postfix="" -on-error="$(PACKER_ON_ERROR)"  -var-file=./images/base-$*.pkrvar.hcl -var manifest_output=$@ vsphere.pkr.hcl

.PHONY: manifests/d2iq-base-%$(NAME_POSTFIX).json.clean
manifests/d2iq-base-%$(NAME_POSTFIX).json.clean: manifests/d2iq-base-%$(NAME_POSTFIX).json
	bash -x mkinclude/helper_deletetemplate.sh $(shell jq -r '.builds[0].custom_data.template' $<)
	mv $< $@

manifests/tests/d2iq-base-%$(NAME_POSTFIX).json: manifests/d2iq-base-%$(NAME_POSTFIX).json clone-test.pkr.hcl
	$(PACKER) build -force -var vsphere_folder=$(VSPHERE_FOLDER) -var vm_name=test-$(shell basename -s .json $<) -var template_manifest=$< -var manifest_output=$@ -on-error="$(PACKER_ON_ERROR)" clone-test.pkr.hcl

manifests/ovf/d2iq-base-%$(NAME_POSTFIX).ovf: manifests/d2iq-base-%$(NAME_POSTFIX).json
	bash mkinclude/helper_markasvm.sh $(VSPHERE_FOLDER)/d2iq-base-$*
	$(GOVC) export.ovf -dc=$(shell jq -r '.builds[0].custom_data.datacenter' $<) -vm=$(VSPHERE_FOLDER)/$(shell jq -r '.builds[0].custom_data.template_name' $<) $@
	tar -czf $@.tar.gz $@/*

# manifests/ova/d2iq-base-%$(NAME_POSTFIX).ova: manifests/ovf/d2iq-base-%$(NAME_POSTFIX).ovf
# 	tar -cvf $@ $</d2iq-base-$*$(NAME_POSTFIX)/*.ovf $</d2iq-base-$*$(NAME_POSTFIX)/*.vmdk

.PHONY: manifests/tests/d2iq-base-%$(NAME_POSTFIX).json.clean
manifests/tests/d2iq-base-%$(NAME_POSTFIX).json.clean: manifests/tests/d2iq-base-%$(NAME_POSTFIX).json
	$(GOVC) vm.destroy /$(shell jq -r '.builds[0].custom_data.datacenter' $<)/vm/$(VSPHERE_FOLDER)/test-$(shell basename -s .json $<)
	mv $< $@

.PHONY: release/d2iq-base-%$(NAME_POSTFIX)
release/d2iq-base-%$(NAME_POSTFIX): manifests/d2iq-base-%$(NAME_POSTFIX).json
	bash mkinclude/helper_deletetemplate.sh $(RELEASE_FOLDER)/d2iq-base-$* || true
	$(GOVC) object.rename /$(shell jq -r '.builds[0].custom_data.datacenter' $<)/vm/$(shell jq -r '.builds[0].custom_data.template_name' $<) d2iq-base-$*
	$(GOVC) object.mv /$(shell jq -r '.builds[0].custom_data.datacenter' $<)/vm/$(VSPHERE_FOLDER)/d2iq-base-$* /$(shell jq -r '.builds[0].custom_data.datacenter' $<)/vm/$(RELEASE_FOLDER)

ubuntu: manifests/d2iq-base-Ubuntu-20.04$(NAME_POSTFIX).json manifests/d2iq-base-Ubuntu-22.04$(NAME_POSTFIX).json
ubuntu-test-20: manifests/tests/d2iq-base-Ubuntu-20.04$(NAME_POSTFIX).json.clean
ubuntu-test-20-clean: ubuntu-test-20 manifests/d2iq-base-Ubuntu-20.04$(NAME_POSTFIX).json.clean 
ubuntu-test-22: manifests/tests/d2iq-base-Ubuntu-22.04$(NAME_POSTFIX).json.clean
ubuntu-test-22-clean: ubuntu-test-22 manifests/d2iq-base-Ubuntu-22.04$(NAME_POSTFIX).json.clean 
ubuntu-test: ubuntu-test-20-clean ubuntu-test-22-clean
ubuntu-release-20: ubuntu-test-20 release/d2iq-base-Ubuntu-20.04$(NAME_POSTFIX)
ubuntu-release-22: ubuntu-test-22 release/d2iq-base-Ubuntu-22.04$(NAME_POSTFIX)
ubuntu-release: ubuntu-release-20 ubuntu-release-22
ubuntu-ovf-20: manifests/ovf/d2iq-base-Ubuntu-20.04$(NAME_POSTFIX).ovf
ubuntu-ovf-22: manifests/ovf/d2iq-base-Ubuntu-22.04$(NAME_POSTFIX).ovf
ubuntu-ovf: ubuntu-ovf-20 ubuntu-ovf-22


rocky: manifests/d2iq-base-RockyLinux-8.7$(NAME_POSTFIX).json manifests/d2iq-base-RockyLinux-9.1$(NAME_POSTFIX).json
rocky-test-87: manifests/tests/d2iq-base-RockyLinux-8.7$(NAME_POSTFIX).json.clean
rocky-test-87-clean: rocky-test-87 manifests/d2iq-base-RockyLinux-8.7$(NAME_POSTFIX).json.clean
rocky-test-91: manifests/tests/d2iq-base-RockyLinux-9.1$(NAME_POSTFIX).json.clean
rocky-test-91-clean: rocky-test-91 manifests/d2iq-base-RockyLinux-9.1$(NAME_POSTFIX).json.clean
rocky-test: rocky-test-87-clean rocky-test-91-clean
rocky-release-87: rocky-test-87 release/d2iq-base-RockyLinux-8.7$(NAME_POSTFIX)
rocky-release-91: rocky-test-91 release/d2iq-base-RockyLinux-9.1$(NAME_POSTFIX)
rocky-release: rocky-release-87 rocky-release-91
rocky-ovf-87: manifests/ovf/d2iq-base-RockyLinux-8.7$(NAME_POSTFIX).ovf
rocky-ovf-91: manifests/ovf/d2iq-base-RockyLinux-9.1$(NAME_POSTFIX).ovf
rocky-ovf: rocky-ovf-87 rocky-ovf-91

centos: manifests/d2iq-base-CentOS-7.9$(NAME_POSTFIX).json
centos-test-79: manifests/tests/d2iq-base-CentOS-7.9$(NAME_POSTFIX).json.clean
centos-test-79-clean: centos-test-79 manifests/d2iq-base-CentOS-7.9$(NAME_POSTFIX).json.clean
centos-test: centos-test-79-clean
centos-release-79: centos-test-79 release/d2iq-base-CentOS-7.9$(NAME_POSTFIX)
centos-release: centos-release-79
centos-ovf-79: manifests/ovf/d2iq-base-CentOS-7.9$(NAME_POSTFIX).ovf
centos-ovf: centos-ovf-79

rhel: manifests/d2iq-base-RHEL-79$(NAME_POSTFIX).json manifests/d2iq-base-RHEL-84$(NAME_POSTFIX).json manifests/d2iq-base-RHEL-86$(NAME_POSTFIX).json
rhel-test-79: manifests/tests/d2iq-base-RHEL-79$(NAME_POSTFIX).json.clean
rhel-test-79-clean: rhel-test-79 manifests/d2iq-base-RHEL-79$(NAME_POSTFIX).json.clean
rhel-test-84: manifests/tests/d2iq-base-RHEL-84$(NAME_POSTFIX).json.clean
rhel-test-84-clean: rhel-test-84 manifests/d2iq-base-RHEL-84$(NAME_POSTFIX).json.clean
rhel-test-86: manifests/tests/d2iq-base-RHEL-86$(NAME_POSTFIX).json.clean
rhel-test-86-clean: rhel-test-86 manifests/d2iq-base-RHEL-86$(NAME_POSTFIX).json.clean
rhel-test: rhel-test-79-clean rhel-test-84-clean rhel-test-86-clean
rhel-release-79: rhel-test-79 release/d2iq-base-RHEL-79$(NAME_POSTFIX)
rhel-release-84: rhel-test-84 release/d2iq-base-RHEL-84$(NAME_POSTFIX)
rhel-release-86: rhel-test-86 release/d2iq-base-RHEL-86$(NAME_POSTFIX)
rhel-release: rhel-release-79 rhel-release-84 rhel-release-86
rhel-ovf-79: manifests/ovf/d2iq-base-RHEL-79$(NAME_POSTFIX).ovf
rhel-ovf-84: manifests/ovf/d2iq-base-RHEL-84$(NAME_POSTFIX).ovf
rhel-ovf-86: manifests/ovf/d2iq-base-RHEL-86$(NAME_POSTFIX).ovf
rhel-ovf: rhel-ovf-79 rhel-ovf-84 rhel-ovf-86

flatcar: manifests/d2iq-base-Flatcar-3033.3.16$(NAME_POSTFIX).json
flatcar-test-3033: manifests/tests/d2iq-base-Flatcar-3033.3.16$(NAME_POSTFIX).json
flatcar-test-3033-clean: flatcar-test-3033 manifests/d2iq-base-Flatcar-3033.3.16$(NAME_POSTFIX).json.clean
flatcar-test: flatcar-test-3033-clean
flatcar-release-3033: flatcar-test-3033 release/d2iq-base-Flatcar-3033.3.16$(NAME_POSTFIX)
flatcar-release: flatcar-release-3033

test-all: ubuntu-test rocky-test centos-test rhel-test
release: ubuntu-release rocky-release centos-release rhel-release
