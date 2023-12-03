#!/bin/sh
set -eux

name=$1

# TODO secureboot

# simple
sudo grub-install --boot-directory=/boot/"$name" --target=x86_64-efi --efi-directory=/efi --bootloader-id="$name"
sudo grub-mkconfig -o newgrub.cfg
echo "copy newgrub.cfg to /boot/$name/grub/grub.cfg"
