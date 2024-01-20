#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options
. "$curdir"/../lib.sh

#NOTE uuid not known if not yet partitioned
drive=$DISK

sgdisk -p "$drive"
ask_continue

sgdisk --zap-all "$drive"

blkdiscard -v "$drive"

sgdisk -og "$drive"
sgdisk -n 1:0:+1G -c 0:"EFI System" -t 0:ef00 "$drive"
# don't use 8200 unless wanting to activate it without encryption
sgdisk -n 2:0:+"$SWAPSIZE" -c 0:"Swap" -t 0:8e00 "$drive"
# luks requires the size of the partition be a multiple of the used sector size (4k)
end_position=$(sgdisk -E "$drive")
sgdisk -n 3:0:"$(( end_position - (end_position + 1) % 2048))" -c 0:"Linux filesystem" -t 0:8300 "$drive"

wipefs --all "$drive"?1
wipefs --all "$drive"?2
wipefs --all "$drive"?3

echo DONE:
sgdisk -p "$drive"

#TODO
# ensure alignment with blockdev --getalignoff
