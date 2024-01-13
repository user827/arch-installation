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

umount -vR "$ROOT"

machinename=arch-installation
machinepath=/var/lib/machines/$machinename
mkdir -p "$machinepath"
mount -vo rbind "$BTRFSROOT"/root "$machinepath"
# For programs needing a working init
mkdir -p /etc/systemd/nspawn
cat >> /etc/systemd/nspawn/$machinename.nspawn <<EOF
[Exec]
NotifyReady=yes

[Network]
VirtualEthernet=no
EOF
machinectl start "$machinename"
journalctl -M "$machinename" -b -p3
for script in "$machinepath"/root/installation/nspawn/*; do
  systemd-run --pty --pipe --wait --collect --service-type=exec -M "$machinename" "${script#"$machinepath"}"
done
machinectl poweroff "$machinename"
umount -vR "$machinepath"

#mkdir -m 700 "$ROOT"/.ssh
#cp /root/.ssh/authorized_keys "$ROOT"/.ssh/

umount "$BTRFSROOT"
echo "Arch OS installation done"
#shutdown -r "+1"
