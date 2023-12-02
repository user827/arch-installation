# Doit

* `export PASS=<sudopass>`
* `make create`
* `make mount` in another shell
* `make setup`
* exit the shell from `make mount`

# TODO

Use pacman packages for as much of the configuration as possible because those
are easier to maintain than ansible scripts.

# Dependencies

* edk2-ovmf

# Debug

export `PACKER_LOG=1`

# Links

* [Arch chroot ansible
  connection](https://www.reddit.com/r/ansible/comments/8kc59a/how_to_use_the_chroot_connection_plugin/)
