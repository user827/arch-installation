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


hwclock --systohc

echo "$IP   $HOSTNAME.$DOMAIN   $HOSTNAME" >> /etc/hosts
