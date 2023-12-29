Scripts for installing arch linux.

# Install

* Configure `scripts/options`.
* Run the scripts in order in `scripts/host` folder.
* Then in `scripts/chroot` folder.
* Reboot.

See `packer/create_chroot.sh` for an example. A password used to access the machine
during installation can be created with `mkpasswd -m sha-512` command of the
`whois` package.

# Post setup

* Enroll secureboot keys.

* Start other service provided by
  [arch-setup](https://github.com/user827/arch-setup).

* Configure sensors with `sensors-detect`.

# Dependencies

* edk2-ovmf
* packer
* qemu
* libvirt

# Testing

Configure `packer/config.auto.pkrvars.hcl` if necessary.
Create virtual machine image
```
cd packer
make ssh_key
make qemuimage
```

Start the image
```
rm OVMF_VARS.fd
./qemu.sh
```

For faster chroot only script testing, use docker:
```
make dockerimage
```

# Debug

Debug packer with
```
export PACKER_LOG=1
```
