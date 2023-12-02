create:
	ansible-playbook create.yml -e @credentials.yml -i host_inventory.yml

mount:
	sudo arch-chroot chroot/mnt

setup:
	sudo ansible-playbook setup.yml -e @credentials.yml -i chroot_inventory.yml

.PHONY: create mount setup
