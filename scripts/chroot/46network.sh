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

mkdir -p /etc/systemd/resolved.conf.d
cat > /etc/systemd/resolved.conf.d/dnssec.conf <<EOF
[Resolve]
DNSSEC=true
EOF

# Don't start the internet if the firewall fails
mkdir /usr/lib/systemd/system/systemd-networkd.service.requires
ln -s /usr/lib/systemd/system/nftables.service /usr/lib/systemd/system/systemd-networkd.service.requires/

systemctl enable systemd-networkd.service
systemctl enable systemd-resolved.service

# enable the default firewall rules
systemctl enable nftables.service
