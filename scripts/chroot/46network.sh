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

pacman -S --noconfirm --ask 4 iptables-nft
sudo -iu devops sh <<EOF
set -eu
git clone https://github.com/user827/network-hardening.git
cd network-hardening
git verify-commit -v HEAD
yay --build -i --answerclean=None --answerdiff=None --noconfirm .
EOF

# Don't start the internet if the firewall fails. No in hardening package
#mkdir /usr/lib/systemd/system/systemd-networkd.service.requires
#ln -s /usr/lib/systemd/system/nftables.service /usr/lib/systemd/system/systemd-networkd.service.requires/

systemctl enable systemd-networkd.service
systemctl enable systemd-resolved.service

# enable the default firewall rules
systemctl enable nftables.service

#inet_iface=$(ip addr show | awk '/inet.*brd/{print $NF; exit}')
cat >> /etc/nftables.conf <<EOF
define inet_iface = "$INET_IFACE"
include "/etc/nftables/*"
EOF
