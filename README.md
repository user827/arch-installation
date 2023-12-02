# Doit

* `export PASS=<sudopass>`
* `make create`
* `make mount` in another shell
* `make setup`
* exit the shell from `make mount`

# TODO

* Use pacman packages for as much of the configuration as possible because those
  are easier to maintain than ansible scripts.

* Libvirt to authenticate with password

# Dependencies

* edk2-ovmf
* packer
* ansible
* vagrant
* qemu
* libvirt
* correct ruby version for vagrant

* vagrant plugin install vagrant-libvirt

# Testing

```
vagrant box add packer_arch_libvirt_amd64.box --name archbox --force
vagrant up --provider=libvirt
sudo virt-viewer vagrant_archvirt
```

# Debug

export `PACKER_LOG=1`

# Links

* [Arch chroot ansible
  connection](https://www.reddit.com/r/ansible/comments/8kc59a/how_to_use_the_chroot_connection_plugin/)
