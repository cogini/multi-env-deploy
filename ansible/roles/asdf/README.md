# Ansible ASDF role

An Ansible Role that installs [asdf](https://github.com/asdf-vm/asdf.git) version manager with plugins.

## Requirements

None

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`). The variable `asdf_plugins` specifies a list of plugins to install:

```yaml
asdf_plugins: []
```

Each plugin can be given in the following format:

```yaml
asdf_plugins:
  - name: "erlang"    # a plugin name
    versions:         # a list of versions to install
      - 18.3
      - 20.1
    global: 20.1      # set as a global version, optional
```

The variable `asdf_user` sets a user for which the role is installed:

```yaml
asdf_user: "deploy"
```

The variable `asdf_legacy_version_file` specifies if plugins which support this feature should read the version files used by other version managers (e.g. `.ruby-version` in the case of Ruby's rbenv).

```yaml
asdf_legacy_version_file: "yes"
```

The variable `asdf_plugin_dependencies` sets packages which are needed for plugins (see `defaults/main.yml`):

```yaml
asdf_plugin_dependencies: []
```

The variable `asdf_version` sets the git tag of asdf:

```yaml
asdf_version: v0.4.3
```

## Dependencies

None

## Example Playbook

Playbook example is given below:

```yaml
- hosts: web
  roles:
  - role: ansible-role-asdf
    asdf_plugins:
    - name: "erlang"
      versions: ["18.3", "20.1"]
      global: "20.1"
    - name: "elixir"
      versions: "1.3.1"
```

A more complex example for CentOS is:

```yaml
- name: install asdf
  hosts: '*'
  become: true
  vars:
    asdf_version: v0.4.3
    asdf_user: ci
    asdf_plugins:
      - name: erlang
      - name: elixir
      - name: nodejs
    asdf_optional_dependencies:
      # Erlang
      - gcc
      - glibc-devel
      - make
      - ncurses-devel
      - openssl-devel
      - autoconf
      - pam-devel
      - perl

      # Node.js
      - gpg
      - perl-Digest-SHA
  roles:
    - asdf
  tasks:
    - name: Set vars
      set_fact:
        asdf_nodejs_keyring: "{{ asdf_user_home }}/.asdf/keyrings/nodejs"

    - name: create keyring for Node.js keys
      file: path={{ asdf_nodejs_keyring }} state=directory owner={{ asdf_user }} {{ asdf_user }} mode=0700

    - name: import Node.js keys to keyring
      command: "bash -lc '{{ asdf_user_home }}/.asdf/plugins/nodejs/bin/import-release-team-keyring'"
      args:
        creates: "{{ asdf_nodejs_keyring }}/pubring.gpg"
      become_user: "{{ asdf_user }}"
      environment:
        GNUPGHOME: "{{ asdf_nodejs_keyring }}"
```

## License

Licensed under the [MIT License](https://opensource.org/licenses/MIT).
