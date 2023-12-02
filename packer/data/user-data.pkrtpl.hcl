#cloud-config

# see https://cloudinit.readthedocs.io/en/latest/reference/examples.html
users:
  - name: ${build_username}
    ssh_authorized_keys:
      - ${build_public_key}
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: true
