create:
	ansible-playbook ansible/create.yml -e @ansible/credentials.yml -i ansible/host_inventory.yml

mount:
	sudo arch-chroot chroot/mnt

setup:
	sudo ansible-playbook ansible/setup.yml -e @ansible/credentials.yml -i ansible/chroot_inventory.yml

.PHONY: create mount setup
