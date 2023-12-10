#!/bin/sh
set -eu

name=$1

grub-install --boot-directory=/boot/"$name" --target=x86_64-efi --efi-directory=/efi --bootloader-id="$name"
grub-mkconfig -o "/boot/$name/grub/grub.cfg.new"
sudo mv -b "/boot/$name/grub/grub.cfg.new" "/boot/$name/grub/grub.cfg"

efibootmgr
