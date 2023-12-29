#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options

mkdir -vp "$BTRFSROOT"
mount -vo subvolid=0,"$MOUNTOPTS" "$ROOTMAPPER" "$BTRFSROOT"

# TODO broken (tested around 2019?), fills too early
#btrfs quota enable root
#btrfs qgroup create 1/100 "$BTRFSROOT"
#btrfs qgroup limit 90G 1/100 "$BTRFSROOT"

btrfs subvolume create "$BTRFSROOT"/root

# For more frequent snapshots
btrfs subvolume create "$BTRFSROOT"/home

btrfs subvolume create "$BTRFSROOT"/var_log
