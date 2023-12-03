check:
	packer init -upgrade .
	packer fmt -recursive .
	packer validate -var=build_version=validate .

validate:
	packer fmt -recursive .
	packer validate -var=build_version=validate .

# For testing the whole setup
qemuimage:
	rm -rf output-arch-qemu packer_arch_qemu.box
	packer build --only=qemu.arch -var=build_version="$(shell git describe --tags --always)-$(shell date +%s)" .

.PHONY: check validate qemuimage
