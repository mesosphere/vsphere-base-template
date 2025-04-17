cdrom
# Use text mode install
text

# Don't run the Setup Agent on first boot
firstboot --disabled

# License agreement
eula --agreed

# System language
lang en_US.UTF-8

# Keyboard layout
keyboard --vckeymap=us --xlayouts='us'

# repo setup
url --mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=rocky-BaseOS-${distribution_version}
repo --name=AppStream --mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=rocky-AppStream-${distribution_version}


# Network information
network --bootproto=dhcp  --onboot=on --device=link --ipv6=auto --activate

### Lock the root account
rootpw --lock

firewall --disabled

# SELinux configuration
selinux --permissive

# Do not configure the X Window System
skipx

# System timezone
timezone UTC

# Add a user named builder
user --name=${ssh_username}
sshkey --username=${ssh_username} "${public_key}"

# System bootloader configuration
bootloader --location=mbr --boot-drive=sda

# Clear the Master Boot Record
zerombr

clearpart --all --initlabel --drives=sda
part / --fstype="ext4" --grow --asprimary --label=slash --ondisk=sda

%packages --excludedocs
# dnf group info minimal-environment
@^minimal-environment
@core
openssh-server
sed
sudo
python3
open-vm-tools

# Exclude unnecessary firmwares
-aic94xx-firmware
-atmel-firmware
-b43-openfwwf
-bfa-firmware
-ipw2100-firmware
-ipw2200-firmware
-ivtv-firmware
-iwl*-firmware
-libertas-usb8388-firmware
-ql*-firmware
-rt61pci-firmware
-rt73usb-firmware
-xorg-x11-drv-ati-firmware
-zd1211-firmware
-cockpit
-quota
-alsa-*
-fprintd-pam
-intltool
-microcode_ctl
%end

%addon com_redhat_kdump --disable
%end

# Enable/disable the following services
services --enabled="sshd,NetworkManager,chronyd"

%post --logfile=/mnt/sysimage/root/ks-post.log --erroronfail
# Disable quiet boot and splash screen
sed --follow-symlinks -i "s/ rhgb quiet//" /etc/default/grub
sed --follow-symlinks -i "s/ rhgb quiet//" /boot/grub2/grubenv
# Passwordless sudo for the user '${ssh_username}'
echo "${ssh_username} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${ssh_username}
chmod 440 /etc/sudoers.d/${ssh_username}

# Remove the package cache
dnf makecache
dnf install epel-release -y
dnf makecache
dnf install -y sudo open-vm-tools perl cloud-init cloud-utils-growpart

systemctl enable vmtoolsd
systemctl start vmtoolsd

# Disable swap
swapoff -a
rm -f /swapfile
sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab
sed -i '/^\(HWADDR\|UUID\)=/d' /etc/sysconfig/network-scripts/ifcfg-* || true
%end

# Reboot after successful installation
reboot
