#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options

echo "$HOSTNAME" > /etc/hostname

ln -s ../usr/share/zoneinfo/"$TIMEZONE" /etc/localtime

sed -ri 's/#.*(en_US.UTF-8 UTF-8)/\1/' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8


# Generate /etc/adjtime
[ -n "${NO_SETUP_HARDWARE:-}" ] || hwclock --systohc

# See man 1 hostname for recommended approach for configuring domain name.
echo "127.0.1.1   $HOSTNAME.$DOMAIN   $HOSTNAME" >> /etc/hosts

# Setup swap
echo "swap	PARTLABEL=Swap	/dev/urandom	swap,cipher=aes-xts-plain64:sha256,size=256" >> /etc/crypttab
echo "/dev/mapper/swap	swap	swap	defaults	0	0" >> /etc/fstab
