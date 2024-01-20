#!/bin/sh
set -eux

# TODO configure basic iptables rules for the duration of the installation

. scripts/options

for script in scripts/host/*; do
  "$script"
done

cp -r scripts "$ROOT"/root/installation
for script in "$ROOT"/root/installation/chroot/*; do
  arch-chroot "$ROOT" "${script#"$ROOT"}"
done

umount -vR "$ROOT"
umount "$BTRFSROOT"
echo "Arch OS installation done"
