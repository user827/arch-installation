#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options

#ssh-keygen -A
#systemctl enable sshd.service
systemctl enable systemd-timesyncd.service

cat > /etc/systemd/network/20-wired.network <<EOF
[Match]
Name=enp*

[Network]
DHCP=yes
EOF
systemctl enable systemd-networkd.service
systemctl enable systemd-resolved.service

ln -s /usr/bin/nvim /usr/local/bin/vim

systemctl enable apparmor.service
