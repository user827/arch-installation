#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options
. "$curdir"/../current

if [ -z "${NO_SETUP_HARDWARE:-}" ]; then
echo 'HOOKS=(base systemd autodetect modconf kms keyboard block sd-encrypt filesystems fsck)' > /etc/mkinitcpio.conf.d/encrypted.conf
echo "FILES+=($KEYFILE)" >> /etc/mkinitcpio.conf.d/encrypted.conf
mkinitcpio -P
fi

[ -z "${NO_SETUP_HARDWARE:-}" ] || exit 0

pacman -S --noconfirm sbctl edk2-shell mokutil
DIFFPROG='nvim -d' aurmatic -S --noconfirm shim-signed

(
. /etc/default/grub
sed -ri "s|(GRUB_CMDLINE_LINUX_DEFAULT)=.*|\\1=\"$GRUB_CMDLINE_LINUX_DEFAULT rd.luks.name=$UUID=root rd.luks.key=$KEYFILE rd.luks.options=luks,discard\"|" /etc/default/grub
)

sed -ri 's/.*(GRUB_ENABLE_CRYPTODISK)=.*/\1=y/' /etc/default/grub
mkdir -m0700 /efi
mount "${DISK}1" /efi

sbctl create-keys
openssl x509 -outform DER -in /usr/share/secureboot/keys/PK/PK.pem -out /efi/EFI/MOK.cer
grubsign --export > "$curdir"/../grubpubkey

cp /usr/share/shim-signed/shimx64.efi /efi/EFI/arch/
cp /usr/share/shim-signed/mmx64.efi /efi/EFI/arch/
cp /usr/share/edk2-shell/x64/Shell.efi /efi/EFI/Shellx64.efi

efibootmgr --unicode --disk /dev/sda --part 1 --create --label "Arch Shim" --loader /EFI/arch/shimx64.efi
"$curdir"/../tools/updategrub.sh arch "$UUID" "$curdir"/../grubpubkey
sbctl sign-all

echo "Enroll shim MOK from ESP\\EFI\\MOK.cer"
echo When using your own PK
echo sbctl enroll-keys --yes-this-might-brick-my-machine
echo And ditch shim

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
sbctl verify
efibootmgr -v
mokutil --list-enrolled
