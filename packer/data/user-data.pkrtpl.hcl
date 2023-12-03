#cloud-config

# see https://cloudinit.readthedocs.io/en/latest/reference/examples.html
users:
  - name: root
    ssh_authorized_keys:
      - ${build_public_key}
