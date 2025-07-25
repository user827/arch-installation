Scripts for installing arch linux.

# Pre setup

* Configure `scripts/options`.
* Check nvme preferred sector size with `nvme` util.
* A password used to access the machine during installation can be created with
  `mkpasswd -m sha-512` command of the `whois` package.

# Install

* Run the scripts in order in `scripts/host` folder.
* Then in `scripts/chroot` folder.
* Reboot.

See `packer/create_chroot.sh` for an example.

# Post setup

* Set fstab to 700 /boot

* Enroll secureboot keys with `sbctl enroll-keys --yolo` or add Microsoft keys
  also. Yolo might break gpu initialization.

* Start other services provided by
  [arch-setup](https://github.com/user827/arch-setup).

* Configure sensors with `sensors-detect`.

* Install linux-my-hardened.

* Configure admin user mail forwarding.

* Gnome settings, keyboard...

* Calibrate display and use its icc profile.

* Configure `/etc/btrbk/btrbk.conf` and enable `backup-daily@daily.timer` and `backup-hourly@hourly.timer` or similar.

* Update nvme firmware with nvme-cli

* Create/import ssh and gpg key

* Configure firefox

* Configure -j $cpucount-2 to makepkg.conf

* X11 device config

* Wayland disable mouse acceleration

* Check device passes fwupd security checks

* Used `edac-util --vv` and see if EDAC registers modules in dmesg to verify ECC
  is enabled.

* Check ecc is enabled by grepping edac in dmesg

* Use `bootctl` to verify secureboot status

# TODO

* gpg pubring.db.lock is held

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
