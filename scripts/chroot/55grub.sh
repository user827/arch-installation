#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options
. "$curdir"/../current

[ -z "${NO_SETUP_HARDWARE:-}" ] || exit 0

pacman -S --noconfirm sbctl edk2-shell mokutil grub efibootmgr linux linux-firmware

echo 'HOOKS=(base systemd autodetect modconf kms keyboard block sd-encrypt filesystems fsck)' > /etc/mkinitcpio.conf.d/encrypted.conf
echo "FILES+=($KEYFILE)" >> /etc/mkinitcpio.conf.d/encrypted.conf
mkinitcpio -P

(
kernel_hardenings="lockdown=confidentiality edac_core.edac_mc_panic_on_ue=1 audit=1 audit_backlog_limit=8192 apparmor=1 intel_iommu=on vsyscall=none slab_nomerge mce=0 pti=on kvm-intel.vmentry_l1d_flush=always spectre_v2_user=on spec_store_bypass_disable=on lsm=lockdown,yama,apparmor page_alloc.shuffle=1 init_on_alloc=1 init_on_free=1 iommu.passthrough=0 iommu.strict=1 randomize_kstack_offset=on mds=full random.trust_cpu=0 tsx=off efi=disable_early_pci_dma hardened_usercopy=1 vdso32=0"
root_options="rd.luks.name=$UUID=root rd.luks.key=$KEYFILE rd.luks.options=luks,discard"

. /etc/default/grub
sed -ri "s|(GRUB_CMDLINE_LINUX_DEFAULT)=.*|\\1=\"$GRUB_CMDLINE_LINUX_DEFAULT $root_options $kernel_hardenings\"|" /etc/default/grub
)
sed -ri 's/.*(GRUB_ENABLE_CRYPTODISK)=.*/\1=y/' /etc/default/grub

mkdir -m0700 /efi
mount "${DISK}1" /efi
mkdir /efi/EFI /efi/EFI/arch

sbctl create-keys
# Required even if the grub uses pubkey when shim-lock is disabled...
sbctl sign -s /boot/vmlinuz-linux

cp /usr/share/edk2-shell/x64/Shell.efi /efi/EFI/Shellx64.efi
sbctl sign -s /efi/EFI/Shellx64.efi

# Fallback entry
"$curdir"/../tools/updategrubunsecure.sh unsecure

"$curdir"/../tools/updategrubsecureboot.sh arch "$UUID"
mkdir /efi/EFI/BOOT
# Autoboot vm
[ -z "${EFI_EXTRA_REMOVABLE:-}" ] || cp /efi/EFI/arch/grubx64.efi /efi/EFI/BOOT/BOOTX64.EFI

echo When using your own PK
echo sbctl enroll-keys --yes-this-might-brick-my-machine
echo or
echo sbctl enroll-keys -m

# TODO Cannot delete the fedora key...
#(
#mkdir keys
#cd keys
#mokutil --export
#for k in *; do
#  [ -f "$k" ] || continue
#  printf '%s\n%s\n' hello hello | mokutil --delete "$k"
#done
#rm -r keys
#)
#echo "Confirm deletion of fedora key with password hello"

sbctl status
# Lsblk does not work in our chroot... TODO
SYSTEMD_ESP_PATH=/efi sbctl verify
efibootmgr
#mokutil --list-enrolled
