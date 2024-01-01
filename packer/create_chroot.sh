#!/bin/sh
set -eux

# TODO configure basic iptables rules for the duration of the installation

. scripts/options
export BATCH=1

# https://bbs.archlinux.org/viewtopic.php?id=283207
# https://bugs.archlinux.org/task/76580
mkdir -m 0755 /root/gnupg
mount --bind /root/gnupg /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate
# At least keyring need to be kept up to date
pacman -Sy --noconfirm archlinux-keyring

for script in scripts/host/*; do
  "$script"
done

cp -r scripts "$ROOT"/root/installation
for script in "$ROOT"/root/installation/chroot/*; do
  arch-chroot "$ROOT" "${script#"$ROOT"}"
done

#mkdir -m 700 "$ROOT"/.ssh
#cp /root/.ssh/authorized_keys "$ROOT"/.ssh/

umount -vR "$ROOT"
umount "$BTRFSROOT"
echo "Arch OS installation done"
#shutdown -r "+1"
