check:
	packer init -upgrade .
	packer fmt -recursive .
	packer validate -var=build_version=validate .

validate:
	packer fmt -recursive .
	packer validate -var=build_version=validate .

# For testing installation inside the chroot
dockerimage:
	packer build --only=docker.arch -var=build_version="$(shell git describe --tags --always)-$(shell date +%s)" .

# For testing the whole setup
qemuimage:
	packer build --only=qemu.arch -var=build_version="$(shell git describe --tags --always)-$(shell date +%s)" .

ssh_key:
	ssh-keygen -f ssh_key

.PHONY: check validate qemuimage
