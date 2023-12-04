#!/bin/sh
set -eux

cd /root
export INSIDE_DOCKER=1
echo "UUID=hello" > scripts/current
pacman -Sy
pacman -S --noconfirm base-devel

. scripts/options

for script in scripts/chroot/*; do
  "$script"
done

echo "Arch OS installation done"
#shutdown -r "+1"
