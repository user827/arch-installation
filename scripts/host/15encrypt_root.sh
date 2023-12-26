#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options
partition=$PARTITION

fdisk -l "$partition"
BATCH=$BATCH SECTOR_SIZE=$SECTOR_SIZE sh "$curdir"/../tools/encrypt_new.sh "$partition"
cryptsetup luksDump "$partition"
lsblk -f "$partition"
blkid -o export "$partition" > "$curdir"/../current
