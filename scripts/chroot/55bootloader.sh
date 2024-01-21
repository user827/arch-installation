#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options
. "$curdir"/../current

[ -z "${NO_SETUP_HARDWARE:-}" ] || exit 0

# TODO umask 077 to boot mount options

pacman -S --noconfirm sbctl
sbctl create-keys
sbctl sign -s /usr/lib/systemd/boot/efi/systemd-bootx64.efi

bootctl install
systemctl enable systemd-boot-update.service

pacman -S --noconfirm mkinitcpio
#echo 'HOOKS=(base systemd autodetect modconf kms keyboard block sd-encrypt filesystems fsck)' > /etc/mkinitcpio.conf.d/encrypted.conf
# Cannot access console on emergency with systemd
echo 'HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt filesystems fsck)' > /etc/mkinitcpio.conf.d/encrypted.conf

pacman -S --noconfirm edk2-shell mokutil efibootmgr linux linux-firmware amd-ucode intel-ucode

UUID=$UUID "$curdir"/../tools/bootloader-mkconfig.sh
# Unified kernel image includes all those

# TODO update systemd-boot hook

# Required even if the grub uses pubkey when shim-lock is disabled...
sbctl sign -s /boot/vmlinuz-linux

cp /usr/share/edk2-shell/x64/Shell.efi /boot/Shellx64.efi
sbctl sign -s /boot/Shellx64.efi

echo When using your own PK
echo sbctl enroll-keys --yes-this-might-brick-my-machine
echo or
echo sbctl enroll-keys -m

sbctl status
# Lsblk does not work in our chroot... TODO
SYSTEMD_ESP_PATH=/boot sbctl verify
efibootmgr
#mokutil --list-enrolled
