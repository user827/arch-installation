#!/bin/sh
set -eux

curdir=$(cd "$(dirname "$0")" && pwd)
. "$curdir"/../options
. "$curdir"/../current

[ -z "${NO_SETUP_HARDWARE:-}" ] || exit 0

# TODO umask 077 to boot mount options

pacman -S --noconfirm sbctl
sbctl create-keys
sbctl sign -s /usr/lib/systemd/boot/efi/systemd-bootx64.efi

bootctl install
systemctl enable systemd-boot-update.service

pacman -S --noconfirm mkinitcpio
#echo 'HOOKS=(base systemd autodetect modconf kms keyboard block sd-encrypt filesystems fsck)' > /etc/mkinitcpio.conf.d/encrypted.conf
# Cannot access console on emergency with systemd
echo 'HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt filesystems fsck)' > /etc/mkinitcpio.conf.d/encrypted.conf

pacman -S --noconfirm edk2-shell mokutil efibootmgr linux linux-firmware amd-ucode intel-ucode

kernel_hardenings="lockdown=confidentiality edac_core.edac_mc_panic_on_ue=1 audit=1 audit_backlog_limit=8192 apparmor=1 intel_iommu=on vsyscall=none slab_nomerge mce=0 pti=on kvm-intel.vmentry_l1d_flush=always spectre_v2_user=on spec_store_bypass_disable=on lsm=landlock,lockdown,yama,safesetid,apparmor,bpf page_alloc.shuffle=1 init_on_alloc=1 init_on_free=1 iommu.passthrough=0 iommu.strict=1 randomize_kstack_offset=on mds=full random.trust_cpu=0 tsx=off efi=disable_early_pci_dma hardened_usercopy=1 vdso32=0"
root_options="cryptdevice=UUID=$UUID:root:allow-discards"
ls /boot/loader
cat /boot/loader/loader.conf
cat <<EOF > /boot/loader/loader.conf
default  arch.conf
timeout  4
console-mode max
editor   yes
EOF
cat <<EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=/dev/mapper/root rw rootflags=subvol=root $root_options $kernel_hardenings
EOF
cat <<EOF > /boot/loader/entries/arch-fallback.conf
title   Arch Linux (Fallback)
linux   /vmlinuz-linux
initrd  /initramfs-linux-fallback.img
options root=/dev/mapper/root rw rootflags=subvol=root $root_options $kernel_hardenings
EOF
# Unified kernel image includes all those

# TODO update systemd-boot hook

# Required even if the grub uses pubkey when shim-lock is disabled...
sbctl sign -s /boot/vmlinuz-linux

cp /usr/share/edk2-shell/x64/Shell.efi /boot/Shellx64.efi
sbctl sign -s /boot/Shellx64.efi

echo When using your own PK
echo sbctl enroll-keys --yes-this-might-brick-my-machine
echo or
echo sbctl enroll-keys -m

sbctl status
# Lsblk does not work in our chroot... TODO
SYSTEMD_ESP_PATH=/boot sbctl verify
efibootmgr
#mokutil --list-enrolled
