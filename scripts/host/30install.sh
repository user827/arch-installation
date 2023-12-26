#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options

# TODO not all configurations succeed
pacstrap -K "$ROOT" base
genfstab -U -p "$ROOT" >> "$ROOT"/etc/fstab
ln -sf ../run/systemd/resolve/stub-resolv.conf "$ROOT"/etc/resolv.conf
