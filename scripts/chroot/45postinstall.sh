#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options
. "$curdir"/../current

etckeeper init
passwd -l root

(
. /etc/default/grub
sed -ri "s|(GRUB_CMDLINE_LINUX_DEFAULT)=.*|\\1=\"$GRUB_CMDLINE_LINUX_DEFAULT rd.luks.name=$UUID=root rd.luks.key=$KEYFILE rd.luks.options=luks,discard\"|" /etc/default/grub
)

echo 'HOOKS=(base systemd autodetect modconf kms keyboard block sd-encrypt filesystems fsck)' > /etc/mkinitcpio.conf.d/encrypted.conf
echo "FILES+=($KEYFILE)" >> /etc/mkinitcpio.conf.d/encrypted.conf
mkinitcpio -P
