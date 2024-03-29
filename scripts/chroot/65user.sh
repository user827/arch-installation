#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options
. "$curdir"/../current

echo "root:$ROOT_ENCRYPTED_PASSWORD" | chpasswd --encrypted

pacman -S --noconfirm zsh
useradd --create-home --user-group --comment "$NORMAL_USER_REAL_NAME" --shell /usr/bin/zsh "$NORMAL_USER"
gpasswd -a "$NORMAL_USER" users
gpasswd -a "$NORMAL_USER" games
# is shit
#homectl create "$NORMAL_USER" --real-name "$NORMAL_USER_REAL_NAME" --storage=subvolume --shell /usr/bin/zsh
echo "$NORMAL_USER ALL=(root) NOPASSWD: ALL" > /etc/sudoers.d/nopasswduser
echo "$NORMAL_USER:$USER_ENCRYPTED_PASSWORD" | chpasswd --encrypted

fpr=0x8DFE60B7327D52D6

script=$(mktemp)
cat > "$script" <<EOF
set -eux
gpg --batch --no-tty --import < /opt/installation/gpgpubkey
printf '5\ny\n' | gpg --command-fd 0 --batch --no-tty --edit-key $fpr trust

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
sudo -iu "$NORMAL_USER" env "BATCH=${BATCH:-}" sh "$script"
rm "$script"

rm /etc/sudoers.d/nopasswduser
cat > /etc/sudoers.d/10sudoers <<EOF
User_Alias SUDOERS = $NORMAL_USER
SUDOERS ALL=(ALL:ALL) ALL
EOF


useradd --create-home --user-group --comment "$ADMIN_USER" --shell /usr/bin/zsh "$ADMIN_USER"
gpasswd -a "$ADMIN_USER" users
# Use sudo
passwd -l "$ADMIN_USER"

# Receive sensitive mail to a protected account
sed -ri "s/^#?root:.*/root: $ADMIN_USER/g" /etc/postfix/aliases
postalias /etc/postfix/aliases

sed -ri 's|#(.*/usr/bin/pinentry-gnome)|\1|' /etc/pinentry/preexec
