#!/bin/bash

set -Eeuxo pipefail

# https://wiki.debian.org/SecureBoot/VirtualMachine
# https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface

curdir=$(cd "$(dirname "$0")" && pwd)

MACHINE_NAME="test"
QEMU_IMG=${1:-"$(printf '%s\n' "$curdir"/output-arch-qemu-*/linux-arch* | tail -1)"}
SSH_PORT="5555"
OVMF_CODE="/usr/share/OVMF/x64/OVMF_CODE.secboot.fd"
OVMF_VARS_TEMPLATE=/usr/share/OVMF/x64/OVMF_VARS.fd
OVMF_VARS="$curdir"/OVMF_VARS.fd

if ! [ -f "$OVMF_VARS" ]; then
  cp "$OVMF_VARS_TEMPLATE" "$OVMF_VARS"
fi

qemu-system-x86_64 \
        -enable-kvm \
        -cpu host -smp cores=4,threads=1 -m 4096 \
        -object rng-random,filename=/dev/urandom,id=rng0 \
        -device virtio-rng-pci,rng=rng0 \
        -name "${MACHINE_NAME}" \
        -drive file="${QEMU_IMG}",format=qcow2 \
        -net nic,model=virtio -net user,hostfwd=tcp::${SSH_PORT}-:22 \
        -vga virtio \
        -machine q35,smm=on \
        -global driver=cfi.pflash01,property=secure,value=on \
        -drive if=pflash,format=raw,unit=0,file="${OVMF_CODE}",readonly=on \
        -drive if=pflash,format=raw,unit=1,file="${OVMF_VARS}"
