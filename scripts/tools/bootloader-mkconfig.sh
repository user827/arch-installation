#!/bin/sh
set -eu
: "${FOLDER:=/boot}"
kernel_hardenings="lockdown=confidentiality edac_core.edac_mc_panic_on_ue=1 audit=1 audit_backlog_limit=8192 apparmor=1 intel_iommu=on vsyscall=none slab_nomerge mce=0 pti=on kvm-intel.vmentry_l1d_flush=always spectre_v2_user=on spec_store_bypass_disable=on lsm=landlock,lockdown,yama,safesetid,apparmor,bpf page_alloc.shuffle=1 init_on_alloc=1 init_on_free=1 iommu.passthrough=0 iommu.strict=1 randomize_kstack_offset=on mds=full random.trust_cpu=0 tsx=off efi=disable_early_pci_dma hardened_usercopy=1 vdso32=0"
root_options="root=/dev/mapper/root cryptdevice=UUID=$UUID:root:allow-discards rw rootflags=subvol=root ${BOOTLOADER_OPTS:-}"
cat <<EOF > "$FOLDER/loader/loader.conf"
default  arch.conf
timeout  4
console-mode max
editor   yes
EOF
cat <<EOF > "$FOLDER/loader/entries/arch.conf"
title   Arch Linux
linux   /vmlinuz-linux${KERNEL_SUFFIX:-}
initrd  /initramfs-linux${KERNEL_SUFFIX:-}.img
options $root_options $kernel_hardenings
EOF
cat <<EOF > "$FOLDER/loader/entries/arch-fallback.conf"
title   Arch Linux (Fallback)
linux   /vmlinuz-linux
initrd  /initramfs-linux-fallback.img
options $root_options $kernel_hardenings
EOF
