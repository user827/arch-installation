#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options

pacstrap "$ROOT" base base-devel
genfstab -U -p "$ROOT" >> "$ROOT"/etc/fstab
mkdir -p "$(dirname "$ROOT$KEYFILE")"
install -m0600 "$KEYFILE" "$ROOT$KEYFILE"
#Keyfile gets in boot
chmod 700 "$ROOT"/boot
