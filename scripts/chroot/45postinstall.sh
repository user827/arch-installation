#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options
. "$curdir"/../current

etckeeper init
#passwd -l root # do later
echo "root:$ROOT_ENCRYPTED_PASSWORD" | chpasswd --encrypted

cat > /etc/postfix/main.cf <<EOF

#For local delivery only
inet_interfaces = loopback-only
mynetworks_style = host
relay_transport = error
relay_domains =
default_transport = error
notify_classes = resource, software, bounce, 2bounce, delay, policy, protocol
EOF

#ssh-keygen -A
#systemctl enable sshd.service
systemctl enable systemd-timesyncd.service
systemctl enable postfix

(
. /etc/default/grub
sed -ri "s|(GRUB_CMDLINE_LINUX_DEFAULT)=.*|\\1=\"$GRUB_CMDLINE_LINUX_DEFAULT rd.luks.name=$UUID=root rd.luks.key=$KEYFILE rd.luks.options=luks,discard\"|" /etc/default/grub
)

if [ -z "${NO_SETUP_HARDWARE:-}" ]; then
  echo 'HOOKS=(base systemd autodetect modconf kms keyboard block sd-encrypt filesystems fsck)' > /etc/mkinitcpio.conf.d/encrypted.conf
  echo "FILES+=($KEYFILE)" >> /etc/mkinitcpio.conf.d/encrypted.conf
  mkinitcpio -P
fi
