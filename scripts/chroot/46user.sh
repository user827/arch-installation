#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options
. "$curdir"/../current

useradd --create-home --user-group --comment "$NORMAL_USER" --shell /usr/bin/zsh "$NORMAL_USER"
gpasswd -a "$NORMAL_USER" users
echo "$NORMAL_USER ALL=(root) NOPASSWD: ALL" > /etc/sudoers.d/user
echo "$NORMAL_USER:$USER_ENCRYPTED_PASSWORD" | chpasswd --encrypted

fpr=0x8DFE60B7327D52D6

sudo -iu "$NORMAL_USER" sh <<EOF
set -eux
gpg --batch --no-tty --passphrase '' --quick-gen-key "$NORMAL_USER" default default
gpg --batch --no-tty --import < /opt/installation/gpgpubkey
printf '5\ny\n' | gpg --command-fd 0 --batch --no-tty --edit-key $fpr trust
printf 'y\ny\n' | gpg --command-fd 0 --batch --no-tty --edit-key $fpr lsign

git clone https://github.com/user827/dotfiles.git
cd dotfiles
git verify-commit -v HEAD
cd pacman/myhome
makepkg --syncdeps --noconfirm --install
cd ../myhomex
makepkg --syncdeps --noconfirm --install
cd ../..
cp options.template options
export BATCH=1
./install.sh
./init.sh
EOF

rm /etc/sudoers.d/user
