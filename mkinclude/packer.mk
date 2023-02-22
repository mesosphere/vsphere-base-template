PACKER_VERSION := 1.8.6
OS ?= $(shell uname|tr A-Z a-z)

uname_m = $(shell uname -m|tr A-Z a-z)

ifeq ($(uname_m),arm64)
	ARCH = "arm64"
else ifeq ($(uname_m),aarch64)
	ARCH = "arm64
else	
	ARCH = amd64
endif


# Path to Terraform binary.
PACKER ?= ./packer.bin

packer.initialized: $(PACKER) vsphere.pkr.hcl
	$(PACKER) init vsphere.pkr.hcl | tee packer.log
	mv packer.log $@

tmp/packer_$(PACKER_VERSION)_$(OS)_$(ARCH).zip:
	wget -nv https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_$(OS)_$(ARCH).zip -O $@

$(PACKER): tmp/packer_$(PACKER_VERSION)_$(OS)_$(ARCH).zip
	unzip -n $<;
	mv ./packer $(PACKER);
	chmod +x $(PACKER);
