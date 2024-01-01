#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options
. "$curdir"/../current

pacman -S --noconfirm gnome
systemctl enable gdm.service
# Needs to be started before gdm to avoid warnings
systemctl enable rtkit-daemon.service
