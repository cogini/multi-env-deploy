# Users

This Ansible role manages user accounts and controls access to them with ssh keys.

It is used to deploy one or more applications to a server. It supports creating
accounts used to deploy and run the app, as well as accounts for system admins
and developers.

It is basically an opinionated wrapper on the
[Ansible user module](http://docs.ansible.com/ansible/latest/user_module.html).

## User types

The role supports creating the following types of user accounts:

* Global system admins / ops team

These users have their own logins on the server with sudo permissions. We add
them to the `wheel` or `admin` group, then allow them to run sudo without a
password.

When we provision a server, we automatically create accounts for our system
admin team, independent of the project.

* Project admins / power users

These users have the same rights as global admins, but are set up on
per-project or per-server basis, controlled with inventory host/group vars.
Normally the tech lead for the project would be an admin.

* Deploy account

This user account is used to deploy the application to the server.  It owns the
application software files and has write permissions to the deploy and config
directories.

The app and deploy accounts do not have sudo permissions, though we may make a
`/etc/sudoers.d/` rule to allow them to run commands to e.g. restart the app by
running `systemctl`. That is handled by the role that installs and configures
the app, not this role.

For example, make a file like `/etc/sudoers.d/deploy-foo`:

    deploy ALL=(ALL) NOPASSWD: /bin/systemctl start foo, /bin/systemctl stop foo, /bin/systemctl restart foo, /bin/systemctl status foo

* App account

The application runs under this user account.

This account has write access to the directories it needs at runtime, e.g.
for logs, and has read-only access to its code and config files.

* Developers

Developers may need to access the deploy or app user account to look at the
logs and debug it. We add the ssh keys for developers to the accounts, allowing
them to log in via ssh.

* Project users

These users are like admins, but don't have sudo. An example might
be an account for a customer to be able to log in and run queries against
the db, but they don't need admin rights. You can give them permissions
to e.g. access the log files for the app by adding them to the app group
and setting file permissions.

# Configuration

By default, this role does nothing. You need to add configuration vars to have
it do something. That would normally be via group vars, e.g.
`inventory/group_vars/app-servers`, a `vars` section in a playbook, or a combination.

You can have different settings on a host or group level to e.g. give
developers login access in the dev environment but not on prod.

## App accounts

The account that deploys the app.
Optional, if not specified the deploy user will not be created.

    users_deploy_user: deploy
    users_deploy_group: deploy

The account that runs the app.
Optional, if not specified the app user will not be created.

    users_app_user: foo
    users_app_group: foo

## User accounts

The `users_users` defines Unix account names and ssh keys
for users.

It is a list of dicts with four fields:

* `user`: Name of the Unix account
* `name`: User's name. Optional, for documentation.
* `key`:  ssh public key file. Put them in e.g. your playbook `files` directory.
* `github` is the user's GitHub id. The role gets the user keys from
`https://github.com/{{ github }}.keys`

Example:

```yaml
users_users:
  - user: jake
    name: "Jake Morrison"
    github: reachfh
  - user: ci
    name: "CI server"
    key: ci.pub
```

## Lists of users

After defining the user accounts in `users_users`, configure lists of users,
specifying the id used in the `user` key. By default, these are empty, so if
you don't specify users, they will not be created.

Global admin users with a separate Unix account and sudo permissions.

```yaml
users_global_admin_users:
 - jake
```

Project level admin users with a separate Unix account and sudo permissions.

```yaml
users_admin_users:
 - fred
```

Project users with a separate Unix account but no sudo permission.

```yaml
users_regular_users:
 - bob
```

Users (ssh keys) who can access the deploy account.

```yaml
users_deploy_users:
 - ci
```

Users (ssh keys) who can access the app account.

```yaml
users_app_users:
 - fred
```

## Group configuration

You can specify additional groups which the different types of users will have.
By default these lists are empty, but you can use it to fine tune access to the app.

We normally configure ssh so that a user account must must be a member of a
`sshusers` group, or ssh will not allow anyone to log in.

Add this to `/etc/ssh/sshd_config`

    AllowGroups sshusers sftpusers

Then add `sshusers` to the `users_admin_groups`, e.g.
```yaml
users_admin_groups:
  - sshusers
```

### Unix groups that admin users should have.

The role will always be added the `wheel` or `admin` group, depending on the
platform. If there are admin users defined, then this role sets up sudo with a
`/etc/sudoers.d/00-admin` file so that admin users can run sudo without a
password.

```yaml
users_admin_groups:
  - sshusers
```

### Unix groups that regular users should have:
```yaml
users_regular_groups:
  - sshusers
```

### Unix groups that the deploy user should have:

```yaml
users_deploy_groups:
  - sshusers
```

### Unix groups that the app user should have:

```yaml
users_app_groups:
  - sshusers
```

## Deleting users

This role defines users that it creates with "ansible-" in the comment.
This allows it to track when users are added or removed from the lists
and delete the accounts.

You can also specify accounts in the `users_delete_users` list and they will be
deleted. This is useful for cleaning up legacy accounts.

You can control whether to delete the user's home directory when deleting the
account with the `users_delete_remove` and `users_delete_force` variables.
See [the Ansible docs](http://docs.ansible.com/ansible/user_module.html) for details.
For safety, these variables are `no` by default, but if you are managing the
system users with this role, you probably want to set them to `yes`.

    users_delete_remove: yes
    users_delete_force: yes

The role can optionally remove authorized keys from system users like 'root' or 'ubuntu'.
This is useful for security to avoid backup root keys, once you have set up named admin
users.

    users_remove_system_authorized_keys: true

## Setup

The normal sequence is to run this role as the first thing on a new instance.
That creates admin users and sets up their keys so that they can run the
other roles which configure the server. A project specific role is responsible
for preparing the server for the app, e.g. creating directories and installing
dependencies. We normally deploy the app from a build or CI server, without sudo,
using the `deploy` user account.

Here is a typical playbook:

```yaml
- name: Manage users
  hosts: '*'
  vars:
    users_app_user: foo
    users_app_group: foo
    users_deploy_user: deploy
    users_deploy_group: deploy
    users_users:
      - user: jake
        name: "Jake Morrison"
        github: reachfh
    users_app_users:
      - jake
    users_deploy_users:
      - jake
  roles:
    - { role: cogini.users, become: true }
```

Add the host to the `inventory/hosts` file.

    [web-servers]
    web-server-01

Add the host to `.ssh/config` or a project specific `ssh.config` file.

    Host web-server-01
        HostName 123.45.67.89

On a physical server where we start with a root account and no ssh keys, we need
to bootstrap the server the first time, specifying the password with -k.

    ansible-playbook -k -u root -v -l web-server-01 playbooks/manage-users.yml --extra-vars "ansible_host=123.45.67.89"

On macOS the -k command requires the askpass utility, which is not installed by
default, so it falls back to paramiko, which doesn't understand `.ssh/config`,
so we specify `ansible_host` manually.

On following runs, after the admin users are set up, use:

    ansible-playbook -u $USER -v -l web-server-01 playbooks/manage-users.yml


## Deleting legacy users

Define legacy user accounts to delete in the `users_delete_users` list, e.g.:

    ansible-playbook -u $USER -v -l web-servers playbooks/manage-users.yml --extra-vars "users_delete_users=[fred] users_delete_remove=yes users_delete_force=yes"

# License

MIT

# Author Information

Jake Morrison at [Cogini](http://www.cogini.com/)
