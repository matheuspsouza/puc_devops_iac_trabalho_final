myhosts:
  hosts:
    ${vm.name}:
      ansible_host: ${vm.public_ip_address}
  vars:
    ansible_user: ${username}
    ansible_password: ${password}