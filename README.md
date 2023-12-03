Scripts for installing arch linux.

# Install

* Configure `scripts/options`.
* Run the scripts in order in `scripts/host` folder.
* Then in `scripts/chroot` folder.
* Reboot.

See `packer/create_chroot.sh` for example. A password used to access the machine
during installation can be created with `mkpasswd -m sha-512` command of the
`whois` package.

# Dependencies

* edk2-ovmf
* packer
* vagrant
* qemu
* libvirt
* correct ruby version for vagrant

* vagrant plugin install vagrant-libvirt

# Testing

Create virtual machine image
```
cd packer
PKR_VAR_root_disk_password=<pw> make qemuimage
vagrant box add packer_arch_libvirt_amd64.box --name archbox --force
```

Start the image
```
cd vagrant
vagrant up --provider=libvirt
sudo virt-viewer vagrant_archvirt
```

# Debug

Debug packer with
```
export PACKER_LOG=1
```
