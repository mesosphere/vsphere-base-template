GOVC_VERSION := 0.30.2
OS ?= $(shell uname)

uname_m = $(shell uname -m)

GOVC_URL ?= $(VSPHERE_USER):$(VSPHERE_PASSWORD)@$(VSPHERE_SERVER)

# Path to govc binary.
export GOVC ?= tmp/govc.bin

tmp/govc_$(GOVC_VERSION)_$(OS)_$(ARCH).tar.gz:
	wget -O $@ -nv https://github.com/vmware/govmomi/releases/download/v$(GOVC_VERSION)/govc_$(OS)_$(uname_m).tar.gz

tmp/govc: tmp/govc_$(GOVC_VERSION)_$(OS)_$(ARCH).tar.gz
	tar -xzf $< -C tmp;

$(GOVC): tmp/govc
	chmod +x $<;
	cp $< $@;
	
