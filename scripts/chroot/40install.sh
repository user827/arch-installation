#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options

pacman -S --noconfirm etckeeper
git config --global user.email root@local
git config --global user.name root
etckeeper init


pacman -S --noconfirm \
  etckeeper vi neovim \
  wget postfix \
  base-devel \
  apparmor \
  man

cat >> /etc/postfix/main.cf <<EOF

#For local delivery only
inet_interfaces = loopback-only
mynetworks_style = host
relay_transport = error
relay_domains =
default_transport = error
notify_classes = resource, software, bounce, 2bounce, delay, policy, protocol
default_destination_rate_delay = 1s
EOF
systemctl enable postfix

# Fetch and build our packages
useradd --create-home --system --user-group --comment devops --shell /bin/sh devops
passwd -l devops
echo 'devops ALL=(root) NOPASSWD: ALL' > /etc/sudoers.d/devops

fpr=0x8DFE60B7327D52D6
mkdir -m 755 /opt/installation
install -m 644 "$curdir"/../gpgpubkey /opt/installation/gpgpubkey

sudo -iu devops sh <<EOF
set -eu
wget https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
tar -xaf yay.tar.gz
cd yay
makepkg --syncdeps --noconfirm --install
EOF

sudo -iu devops sh <<EOF
set -eu
gpg --batch --no-tty --import < /opt/installation/gpgpubkey
printf '5\ny\n' | gpg --command-fd 0 --batch --no-tty --edit-key $fpr trust

git clone https://github.com/user827/shlib.git
cd shlib
git verify-commit -v HEAD
cp PKGBUILD.template PKGBUILD
yay --build -i --answerclean=None --answerdiff=None --noconfirm .
EOF

sudo -iu devops sh <<EOF
set -eu
git clone https://github.com/user827/arch-setup.git
cd arch-setup
git verify-commit -v HEAD
yay --build -i --answerclean=None --answerdiff=None --noconfirm .
EOF
systemctl enable sensord-rrd.service mylighttpd.service
systemctl enable myreflector.timer aur.timer
systemctl enable sec-journal.service sec-journal-warn.service sec-audit.service
systemctl enable smartd.service auditd.service
systemctl enable ras-mc-ctl.service rasdaemon.service

ln -s /usr/bin/nvim /usr/local/bin/vim
systemctl enable apparmor.service

# default 3 is annoying
echo 'deny = 30' > /etc/security/faillock.conf

sudo -iu devops sh <<EOF
set -eu
git clone https://github.com/user827/btrfs-setup.git
cd btrfs-setup
git verify-commit -v HEAD
makepkg --syncdeps --noconfirm --install
EOF
systemctl enable btrfs-balance@-.service btrfs-scrub-resume@-.service btrfs-scrub@-.timer
