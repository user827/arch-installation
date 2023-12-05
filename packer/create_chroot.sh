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
cp -r scripts/chroot "$ROOT"/root/installation/
cp -r scripts/tools "$ROOT"/root/installation/
cp scripts/current "$ROOT"/root/installation/
cp scripts/options "$ROOT"/root/installation/
cp scripts/gpgpubkey "$ROOT"/root/installation/
for script in "$ROOT"/root/installation/chroot/*; do
  arch-chroot "$ROOT" "${script#"$ROOT"}"
done

#mkdir -m 700 "$ROOT"/.ssh
#cp /root/.ssh/authorized_keys "$ROOT"/.ssh/

umount -vR "$ROOT"
umount "$BTRFSROOT"
echo "Arch OS installation done"
#shutdown -r "+1"
