#!/bin/sh
set -eux

#curdir=$(cd "$(dirname "$0")" && pwd)
#. "$curdir"/../options
#. "$curdir"/../current

pacman -S --noconfirm apparmor

kernel_hardenings="lockdown=confidentiality edac_core.edac_mc_panic_on_ue=1 audit=1 audit_backlog_limit=8192 apparmor=1 security=apparmor intel_iommu=on vsyscall=none slab_nomerge mce=0 pti=on kvm-intel.vmentry_l1d_flush=always spectre_v2_user=on spec_store_bypass_disable=on lsm=lockdown,yama,apparmor page_alloc.shuffle=1 init_on_alloc=1 init_on_free=1 iommu.passthrough=0 iommu.strict=1 randomize_kstack_offset=on mds=full random.trust_cpu=0 tsx=off efi=disable_early_pci_dma hardened_usercopy=1 vdso32=0"
(
. /etc/default/grub
sed -ri "s|(GRUB_CMDLINE_LINUX_DEFAULT)=.*|\\1=\"$GRUB_CMDLINE_LINUX_DEFAULT $kernel_hardenings\"|" /etc/default/grub
)
