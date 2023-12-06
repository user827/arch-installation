#!/bin/sh
set -eu

name=$1
root_uuid=$2
pubkeypath=$3

# simple
# shim lock not needed when the kernel files are encrypted?
grub-install --boot-directory=/boot/"$name" --target=x86_64-efi --efi-directory=/efi --bootloader-id="$name" --pubkey="$pubkeypath" --disable-shim-lock
cfg=$(mktemp)
uuid=$(echo "$root_uuid" | tr -d -)

cat > "$cfg" <<EOF
set check_signatures=enforce
export check_signatures
echo "Prefix: '\$prefix'"
echo "Signature checking: '\$check_signatures'"
insmod part_gpt
insmod luks2
cryptomount -u $uuid
configfile (crypto0)/root/boot/$name/grub/grub.cfg
EOF
grub-mkstandalone --modules="gcry_sha256 gcry_sha512 gcry_dsa gcry_rsa" --sbat /usr/share/grub/sbat.csv --format x86_64-efi -o "/efi/EFI/$name/grubx64.efi" --pubkey "$pubkeypath" --disable-shim-lock "boot/grub/grub.cfg=$cfg"
rm "$cfg"

sbctl sign -s /efi/EFI/"$name"/grubx64.efi
grub-mkconfig -o "/boot/$name/grub/grub.cfg.new"
sudo mv -b "/boot/$name/grub/grub.cfg.new" "/boot/$name/grub/grub.cfg"
grubsign "/boot/$name/grub/grub.cfg"
grubsign --sign-all

efibootmgr
