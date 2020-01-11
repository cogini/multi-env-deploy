# cronic

Install [cronic](https://habilis.net/cronic/) from a local copy.

# Role Variables

Directory to install script into

    cronic_install_dir: /opt/bin

# Example Playbook

    - hosts: '*'
      become: true
      roles:
         - cronic

# License

MIT

# Author Information

Jake Morrison <jake@cogini.com>
