#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options

# TODO not all configurations succeed
pacstrap -K "$ROOT" base
genfstab -U -p "$ROOT" >> "$ROOT"/etc/fstab
mkdir -p "$(dirname "$ROOT$KEYFILE")"
install -m0600 "$KEYFILE" "$ROOT$KEYFILE"
#Keyfile gets in boot
chmod 700 "$ROOT"/boot
