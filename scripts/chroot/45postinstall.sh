#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options

etckeeper init
passwd -l root
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
