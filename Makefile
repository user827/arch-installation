setup:
	sudo ansible-playbook ansible/setup.yml -e @ansible/credentials.yml -i ansible/host_inventory.yml

.PHONY: setup
