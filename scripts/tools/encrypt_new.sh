#!/bin/sh
set -eux

vol=$1
cryptkey=$2
: "${SECTOR_SIZE:=4096}"

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../lib.sh

fdisk -l "${vol%[0-9]}"
echo "overwriting data on $vol (key $cryptkey)"
ask_continue

# Grub does not support argo yet
cryptsetup luksFormat "${BATCH:+--batch-mode}" --sector-size "$SECTOR_SIZE" --use-random --type luks2 --hash sha256 --pbkdf pbkdf2 "$vol" "$cryptkey"
if [ "$BATCH" = 1 ]; then
  printf '%s' "$CRYPT_PASSWORD" | cryptsetup luksAddKey "${BATCH:+--batch-mode}" --key-file "$cryptkey" "$vol" --new-keyfile=-
else
  cryptsetup luksAddKey --key-file "$cryptkey" "$vol"
fi
