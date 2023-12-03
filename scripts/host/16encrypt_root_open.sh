#!/bin/sh
set -eu

curdir=$(cd "$(dirname "$0")" && pwd)
if [ -f "$curdir"/../current ]; then
  . "$curdir"/../current
fi
. "$curdir"/../options
partition=${1:-$PARTITION}
keyfile=$KEYFILE

cryptsetup luksOpen --key-file="$keyfile" "$partition" "${ROOTMAPPER##*/}"
echo "$partition open in $ROOTMAPPER"
