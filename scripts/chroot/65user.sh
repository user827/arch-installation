#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options
. "$curdir"/../current

echo "root:$ROOT_ENCRYPTED_PASSWORD" | chpasswd --encrypted

pacman -S --noconfirm zsh
useradd --create-home --user-group --comment "$NORMAL_USER" --shell /usr/bin/zsh "$NORMAL_USER"
gpasswd -a "$NORMAL_USER" users
echo "$NORMAL_USER ALL=(root) NOPASSWD: ALL" > /etc/sudoers.d/nopasswduser
echo "$NORMAL_USER:$USER_ENCRYPTED_PASSWORD" | chpasswd --encrypted

fpr=0x8DFE60B7327D52D6

script=$(mktemp)
cat > "$script" <<EOF
set -eux
gpg --batch --no-tty --passphrase '' --quick-gen-key "$NORMAL_USER" default default
gpg --batch --no-tty --import < /opt/installation/gpgpubkey
printf '5\ny\n' | gpg --command-fd 0 --batch --no-tty --edit-key $fpr trust
printf 'y\ny\n' | gpg --command-fd 0 --batch --no-tty --edit-key $fpr lsign

git clone https://github.com/user827/dotfiles.git
cd dotfiles
git verify-commit -v HEAD
cd pacman/myhome
yay --build -i --answerclean=None --answerdiff=None --noconfirm .
cd ../myhomex
yay --build -i --answerclean=None --answerdiff=None --noconfirm .
cd ../..
cp options.template options
./install.sh
./init.sh
EOF
chown "$NORMAL_USER": "$script"
sudo -iu "$NORMAL_USER" env "BATCH=$BATCH" sh "$script"
rm "$script"

rm /etc/sudoers.d/nopasswduser
echo "User_Alias SUDOERS = $NORMAL_USER" > /etc/sudoers.d/sudoers
echo "SUDOERS ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/sudoers


useradd --create-home --user-group --comment "$ADMIN_USER" --shell /usr/bin/zsh "$ADMIN_USER"
gpasswd -a "$ADMIN_USER" users
echo "$ADMIN_USER:$ADMIN_ENCRYPTED_PASSWORD" | chpasswd --encrypted

# Receive senstitive mail to a protected account
sed -i "s/^root:.*/root: $ADMIN_USER/g" /etc/postfix/aliases
postalias /etc/postfix/aliases
