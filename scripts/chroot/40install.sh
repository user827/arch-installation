#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options


pacman -S --noconfirm \
  btrfs-progs etckeeper \
  wget postfix \
  base-devel

# Fetch and build our packages
useradd --create-home --system --user-group --comment devops --shell /bin/sh devops
passwd -l devops
echo 'devops ALL=(root) NOPASSWD: ALL' > /etc/sudoers.d/devops

fpr=0x8DFE60B7327D52D6
mkdir -m 755 /opt/installation
install -m 644 "$curdir"/../gpgpubkey /opt/installation/gpgpubkey

sudo -iu devops sh <<EOF
set -eu
gpg --batch --no-tty --passphrase '' --quick-gen-key devops default default
gpg --batch --no-tty --import < /opt/installation/gpgpubkey
printf '5\ny\n' | gpg --command-fd 0 --batch --no-tty --edit-key $fpr trust
printf 'y\ny\n' | gpg --command-fd 0 --batch --no-tty --edit-key $fpr lsign

git clone https://github.com/user827/shlib.git
cd shlib
git verify-commit -v HEAD
cp PKGBUILD.template PKGBUILD
makepkg --syncdeps --noconfirm --install
EOF

sudo -iu devops sh <<EOF
set -eu
wget https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
tar -xaf yay.tar.gz
cd yay
makepkg --syncdeps --noconfirm --install
EOF

sudo -iu devops sh <<EOF
set -eu
git clone https://github.com/user827/arch-setup.git
cd arch-setup
git verify-commit -v HEAD
cp PKGBUILD.template PKGBUILD
makepkg --syncdeps --noconfirm --install
EOF
