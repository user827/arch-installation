#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options


# dependencies for ansible also
pacman -S --noconfirm \
  python openssh \
  btrfs-progs etckeeper \
  grub efibootmgr

ssh-keygen -A
systemctl enable sshd.service
systemctl enable systemd-timesyncd.service
