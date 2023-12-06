#!/bin/sh
set -eux

name=$1
root_uuid=$2

# simple
# shim lock not needed when the kernel files are encrypted?
grub-install --boot-directory=/boot/"$name" --target=x86_64-efi --efi-directory=/efi --bootloader-id="$name"
cfg=$(mktemp)
uuid=$(echo "$root_uuid" | tr -d -)
cat > "$cfg" <<EOF
echo "Prefix: '\$prefix'"
echo "Signature checking: '\$check_signatures'"
insmod part_gpt
insmod luks2
cryptomount -u $uuid
configfile (crypto0)/root/boot/$name/grub/grub.cfg
EOF
grub-mkstandalone --format x86_64-efi -o "/efi/EFI/$name/grubx64.efi" --sbat /usr/share/grub/sbat.csv "boot/grub/grub.cfg=$cfg"
grub-mkconfig -o newgrub.cfg
echo "copy newgrub.cfg to /boot/$name/grub/grub.cfg"
rm "$cfg"

echo TODO looses shim?
efibootmgr -v
