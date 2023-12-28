#!/bin/sh
set -eux

vol=$1
: "${SECTOR_SIZE:=4096}"

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../lib.sh

fdisk -l "${vol%[0-9]}"
echo "overwriting data on $vol"
ask_continue

set -- --sector-size "$SECTOR_SIZE" --use-random --type luks2
if [ "$BATCH" = 1 ]; then
  printf '%s' "$CRYPT_PASSWORD" | cryptsetup luksFormat --batch-mode "$@" --key-file=- "$vol"
else
  cryptsetup luksAddKey "$@" "$vol"
fi
