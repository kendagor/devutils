#! /usr/bin/bash

sudo apt install -y \
    libvirt-clients-qemu \
    libvirt-daemon-driver-qemu \
    ovmf \
    qemu-system-common \
    qemu-system-data \
    qemu-utils \
    qemu-system-modules-opengl \
    qemu-system-gui \
    qemu-system-x86

# Test is you would like to use:
# qemu-web-desktop : https://salsa.debian.org/debian/qemu-web-desktop

# In an Ubuntu VM (guest system) consider installing:
# qemu-guest-agent
