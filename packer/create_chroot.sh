#!/bin/sh
set -eux

# TODO configure basic iptables rules for the duration of the installation

. scripts/options

mkdir -p "$(dirname "$KEYFILE")"
dd bs=512 count=4 if=/dev/random of="$KEYFILE" iflag=fullblock

for script in scripts/host/*; do
  "$script"
done

mkdir "$ROOT"/root/installation
cp -r scripts/chroot "$ROOT"/root/installation/chroot
cp -r scripts/current "$ROOT"/root/installation/current
cp -r scripts/gpgpubkey "$ROOT"/root/installation/gpgpubkey
cp scripts/options "$ROOT"/root/installation/
for script in "$ROOT"/root/installation/chroot/*; do
  arch-chroot "$ROOT" "${script#"$ROOT"}"
done

sed -ri 's/.*(GRUB_ENABLE_CRYPTODISK)=.*/\1=y/' "$ROOT"/etc/default/grub
cp scripts/tools/updategrub.sh "$ROOT"/root/installation/
mkdir -m0700 "$ROOT"/efi
mount "${DISK}1" "$ROOT"/efi
arch-chroot "$ROOT" /root/installation/updategrub.sh grub
mv "$ROOT"/newgrub.cfg "$ROOT"/boot/grub/grub/grub.cfg

mkdir -m 700 "$ROOT"/.ssh
cp /root/.ssh/authorized_keys "$ROOT"/.ssh/

umount -vR "$ROOT"
umount "$BTRFSROOT"
echo "Arch OS installation done"
#shutdown -r "+1"
