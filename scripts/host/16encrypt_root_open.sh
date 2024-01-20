#!/bin/sh
set -eu

curdir=$(cd "$(dirname "$0")" && pwd)
if [ -f "$curdir"/../current ]; then
  . "$curdir"/../current
fi
. "$curdir"/../options
partition=${1:-$PARTITION}

if [ "${BATCH:-}" = 1 ]; then
  printf '%s' "$CRYPT_PASSWORD" | cryptsetup luksOpen --key-file=- "$partition" "${ROOTMAPPER##*/}"
else
  cryptsetup luksOpen --key-file=- "$partition" "${ROOTMAPPER##*/}"
fi
echo "$partition open in $ROOTMAPPER"
