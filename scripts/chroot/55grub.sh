#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options
#. "$curdir"/../current

[ -z "${NO_SETUP_HARDWARE:-}" ] || exit 0

sed -ri 's/.*(GRUB_ENABLE_CRYPTODISK)=.*/\1=y/' /etc/default/grub
mkdir -m0700 /efi
mount "${DISK}1" /efi
"$curdir"/../tools/updategrub.sh grub
mv newgrub.cfg /boot/grub/grub/grub.cfg
