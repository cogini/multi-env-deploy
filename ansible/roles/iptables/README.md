# iptables

Set up iptables using [ansible_iptables_raw](https://github.com/Nordeus/ansible_iptables_raw).

# Requirements

Download [iptables_raw.py](https://raw.githubusercontent.com/Nordeus/ansible_iptables_raw/master/iptables_raw.py)
and put it in your top level `library` directory.

# Role Variables

See the documentation for [ansible_iptables_raw](https://github.com/Nordeus/ansible_iptables_raw).

# Example Playbook

Including an example of how to use your role (for instance, with variables
passed in as parameters) is always nice for users too:

```yaml
- name: Install iptables
  hosts: '*'
  become: true
  vars:
    iptables_ssh_ports:
      - 22
      - 1022
  roles:
    - iptables
```

# License

MIT

# Author Information

Jake Morrison <jake@cogini.com>
