#!/bin/sh
set -eu

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options

mkdir -vp "$ROOT"
mount -vo rbind "$BTRFSROOT"/root "$ROOT"

mkdir -vm 755 "$ROOT"/home "$ROOT"/var/ "$ROOT"/var/log #"$ROOT"/var/cache "$ROOT"/var/cache/pacman
mount -vo rbind "$BTRFSROOT"/home "$ROOT"/home
mount -vo rbind "$BTRFSROOT"/var_log "$ROOT"/var/log
#mount -vo subvol=$PACMANSUBVOL "$PACMANBTRFSDEV" "$ROOT"/var/cache/pacman

mkdir "$ROOT"/boot
mount "$EFI_PARTITION" "$ROOT"/boot
