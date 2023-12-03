#!/bin/sh
set -eu

name=$1

# TODO secureboot

# simple
sudo grub-install --boot-directory=/boot/"$name" --target=x86_64-efi --efi-directory=/mnt/esp/part --bootloader-id="$name"
sudo grub-mkconfig -o newgrub.cfg
echo "copy newgrub.cfg to /boot/$name/grub/grub.cfg"
