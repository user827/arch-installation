#!/bin/sh
set -eu
: "${FOLDER:=/boot}"
kernel_hardenings="oops=panic lockdown=confidentiality edac_core.edac_mc_panic_on_ue=1 audit=1 audit_backlog_limit=8192 apparmor=1 amd_iommu=on intel_iommu=on vsyscall=none slab_nomerge mce=0 pti=on kvm-intel.vmentry_l1d_flush=always lsm=landlock,lockdown,yama,safesetid,apparmor,bpf page_alloc.shuffle=1 init_on_alloc=1 init_on_free=1 iommu.passthrough=0 iommu.strict=1 randomize_kstack_offset=on random.trust_cpu=0 efi=disable_early_pci_dma hardened_usercopy=1 vdso32=0 mitigations=auto"
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
initrd  /intel-ucode.img
initrd  /amd-ucode.img
initrd  /initramfs-linux${KERNEL_SUFFIX:-}.img
options $root_options $kernel_hardenings
EOF
cat <<EOF > "$FOLDER/loader/entries/arch-fallback.conf"
title   Arch Linux (Fallback)
linux   /vmlinuz-linux${KERNEL_SUFFIX:-}
initrd  /intel-ucode.img
initrd  /amd-ucode.img
initrd  /initramfs-linux${KERNEL_SUFFIX:-}-fallback.img
options $root_options $kernel_hardenings
EOF
