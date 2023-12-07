#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options
. "$curdir"/../current

[ -z "${NO_SETUP_HARDWARE:-}" ] || exit 0

pacman -S --noconfirm sbctl edk2-shell mokutil grub efibootmgr linux linux-firmware

echo 'HOOKS=(base systemd autodetect modconf kms keyboard block sd-encrypt filesystems fsck)' > /etc/mkinitcpio.conf.d/encrypted.conf
echo "FILES+=($KEYFILE)" >> /etc/mkinitcpio.conf.d/encrypted.conf
mkinitcpio -P

(
. /etc/default/grub
sed -ri "s|(GRUB_CMDLINE_LINUX_DEFAULT)=.*|\\1=\"$GRUB_CMDLINE_LINUX_DEFAULT rd.luks.name=$UUID=root rd.luks.key=$KEYFILE rd.luks.options=luks,discard\"|" /etc/default/grub
)
sed -ri 's/.*(GRUB_ENABLE_CRYPTODISK)=.*/\1=y/' /etc/default/grub

mkdir -m0700 /efi
mount "${DISK}1" /efi
mkdir /efi/EFI /efi/EFI/arch

sbctl create-keys
# Required even if the grub uses pubkey when shim-lock is disabled...
sbctl sign -s /boot/vmlinuz-linux

cp /usr/share/edk2-shell/x64/Shell.efi /efi/EFI/Shellx64.efi
sbctl sign -s /efi/EFI/Shellx64.efi

"$curdir"/../tools/updategrub.sh arch "$UUID"
mkdir /efi/EFI/BOOT
# Autoboot vm
[ -z "${EFI_EXTRA_REMOVABLE:-}" ] || cp /efi/EFI/arch/grubx64.efi /efi/EFI/BOOT/BOOTX64.EFI

echo When using your own PK
echo sbctl enroll-keys --yes-this-might-brick-my-machine
echo or
echo sbctl enroll-keys -m

# TODO Cannot delete the fedora key...
#(
#mkdir keys
#cd keys
#mokutil --export
#for k in *; do
#  [ -f "$k" ] || continue
#  printf '%s\n%s\n' hello hello | mokutil --delete "$k"
#done
#rm -r keys
#)
#echo "Confirm deletion of fedora key with password hello"

sbctl status
# Lsblk does not work in our chroot... TODO
SYSTEMD_ESP_PATH=/efi sbctl verify
efibootmgr
#mokutil --list-enrolled
