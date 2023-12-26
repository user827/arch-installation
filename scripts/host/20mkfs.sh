#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options

# TODO should use raid1 instead?
mkfs.btrfs -L root "$ROOTMAPPER"
mkfs.fat -F32 -n ESP "$EFI_PARTITION"
