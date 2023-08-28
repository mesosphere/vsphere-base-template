#!/bin/bash

# Disable flatcar autologin
sed -i '/flatcar.autologin/d' /usr/share/oem/grub.cfg
