# Ansible

Ansible is used to set up AMIs, perform tasks like creating db users, and
generate config files in S3 buckets from templates. We may use the Ansible
vault to store secrets or put them into SSM Parameter Store.

## Structure

The structure generally follows the approach in "[Setting Ansible variables
based on the environment](https://www.cogini.com/blog/setting-ansible-variables-based-on-the-environment/)".

Ansible normally uses the inventory to identify the hosts that are being
managed and set configuration variables at a host or group level.

Because we are managing multiple environments, we do most configuration under
the `vars` directory, pulled in explicitly by playbooks when e.g. building
AMIs.

You can, however, configure settings that apply to your whole system
and use Ansible to manage individual instances.

## Hosts

Ansible references hosts using the name ssh knows them by, e.g. in
your `~/.ssh/config`:

    Host web-server
        HostName 123.45.67.89

We use a shared `ssh.config` file checked into git it's loaded
by default when running Ansible. See `ansible.cfg` for details.
`ProxyJump` commands allow you to access machines in the VPC private network by
bouncing through the bastion host.

To connect:

```bash
export APP=foo
export ENV=prod

# Single instances
ssh -F ssh.config $APP-$ENV-bastion
ssh -F ssh.config $APP-$ENV-devops

# One random instance from the ASG
ssh -F ssh.config $APP-$ENV-app
ssh -F ssh.config $APP-$ENV-cron
ssh -F ssh.config $APP-$ENV-worker
```

The `app`, `cron` and `worker` instances run inside ASGs, so there may be more
than one instance. `ssh -F ssh.config $APP-$ENV-app` will connect to one
instance in the ASG, selected at random, each time the command is run. If you
need to connect to a specific instance, you will need to find the local IP of
the instance in the form `10.10.x.x`. Once you have the local IP, you can
connect directly to it.

```bash
cd ansible
export APP=foo
export ENV=prod

ssh -F ssh.config 10.10.2.52
ssh -F ssh.config 10.10.x.x






In the cloud, we don't have many fixed servers, mostly just
the bastion host used to access servers in the private part of the VPC.

`inventory/static-hosts.yml` defines static hosts, things that do not change.

Most hosts in the cloud are more dynamic, e.g. in an auto scaling group.
We also have multiple copies, one per environment (dev, prod).

Ansible's dynamic inventory queries AWS and puts instances into groups
based on tags. `inventory/aws_ec2.yml` configures it, and
groups are defined in `inventory/hosts.yml`.

## Groups

Group variables are set in `inventory/group_vars`.

Files in `inventory/group_vars/all` set defaults for all hosts.
They are overridden by more specific group settings.

Other than `all`, Ansible does not have priority between groups, one does not
override the other. Best practice is to specify a variable in exactly one
group, and not expect to override settings. This can be a pain, so we
mostly end up specifying variables under `vars` by app and env.

Here is an example of using group settings:

```
all
    users.yml
    vars.yml
tag_app_foo
    all.yml
tag_comp_app
    all.yml
tag_env_dev
    all.yml
    users.yml
tag_env_prod
    all.yml
```

`inventory/group_vars/all/vars.yml` sets defaults for all hosts.

* `org` is a short name for the org that owns the system, e.g. company or project
* `org_unique` is a globally unique name used for things like S3 buckets
* `aws_region` is the primary AWS region

`inventory/group_vars/all/users.yml`

This is defines defaults for the [cogini.users](https://galaxy.ansible.com/cogini/users)
role. You can use it to e.g. make sure that ops users have a login with sudo on all servers.

The other groups depend on tags, e.g. if an instance is tagged with `app=foo`, it would
load group vars from `tag_app_foo/all.yml`.

## Variables

Under `vars`, we set a hierarchy of variable include files which is referenced
when running the playbook using environment vars.

    vars/
    └── foo
        ├── common
        └── dev
            ├── app-https.yml
            ├── app-secrets.yml
            ├── app.yml
            ├── bastion.yml
            ├── common.yml
            ├── db-app.yml
            ├── devops.yml
            └── elixir-release.yml

```shell
vars/$APP/$ENV/$COMP.yml
vars/$APP/$ENV/$COMP-secrets.yml
vars/$APP/$ENV/db-$COMP.yml
```

For example, with the following set of config files:

    vars
    └── foo
        └── dev
            ├── app-secrets.yml
            ├── app.yml
            ├── common.yml
            └── db-app.yml

The playbook would load common settings for the dev environment, app settings,
connection settings for the app db, and other app secrets like API keys:

```shell
ansible-playbook -u $USER -v -l app-server playbooks/foo/packer-app.yml
```

```yaml
  vars_files:
    - vars/foo/{{ env }}/common.yml
    - vars/foo/{{ env }}/app.yml
    - vars/foo/{{ env }}/db-app.yml
    - vars/foo/{{ env }}/app-secrets.yml
```

These are explicitly loaded by playbooks. You can also create common vars files
wherever makes sense in your hierarchy.

`files` has common files used by the playbooks, e.g. ssh public keys used by
`manage-users.yml`.

## Overriding templates

You can override the templates used by playbooks or roles based on the environment
using files in `templates`. This allows you to write more generic playbooks
and roles which can still be configured when necessary.

For example, the `foo/config-app.yml` playbook generates a config
file for an app based on configuration variables in Ansible.

It sets the `input_template` variable based on the app component:

```yaml
input_template: ../../templates/{{ app_name }}/{{ comp }}/config.{{ file_format }}.j2
```

Then it generates the config file to a temp file and uploads it to S3.

```yaml
- name: Fill template to tempfile
  template:
    src: "{{ input_template }}"
    dest: "{{ temp_file.path }}"
  no_log: true
```

Roles can be written in a similar way, for example, `nginx-app` role
defines variables in `roles/nginx-app/defaults/main.yml`:

```yaml
nginx_app_systemd_override_template: etc/systemd/system/nginx.service.d/override.conf.j2
nginx_app_nginx_conf_template: etc/nginx/nginx.conf.j2
nginx_app_default_conf_template: etc/nginx/conf.d/default.conf.j2
nginx_app_localhost_conf_template: etc/nginx/conf.d/localhost.conf.j2
```

That variable can be overridden by a playbook to use e.g.
`templates/foo/app/nginx-app/etc/nginx/conf.d/default.conf.j2`.


## Playbooks

Playbooks are lists of tasks to run against servers.

They are grouped by app, and are generally written to
get the the env from in a variable.

```
manage-users.yml
files
foo
    app-ssm.yml
    bastion.yml
    bootstrap-db-mysql.yml
    bootstrap-db-pg.yml
    bootstrap-db-ssm.yml
    config-app-https.yml
    config-app.yml
    devops.yml
    packer-app.yml
```

Playbooks are named by function and component:

### Packer

Playbooks with prefix `packer` like `packer-$COMP.yml` are run from packer to
configure an AMI for the component.

### Standalone instances

Playbooks like `bastion.yml` and `devops.yml` run against standalone EC2 instances.

### Boostrap DB

Playbooks like `bootstrap-db-$COMP.yml` do initial configuration of RDS database
using secrets.

* bootstrap-db-mysql.yml
* bootstrap-db-pg.yml
* bootstrap-db-ssm.yml
* app-ssm.yml

### App configuration

Playbooks like `playbooks/$APP/config-$COMP.yml` generate the configuration for
an app.  This pulls information from the environment like host names and
secrets from the Ansible vault.

They might generate an output file and put it to an S3 bucket or put them in
AWS SSM Parameter Store.

`config-$COMP-https.yml` generates SSL certs for HTTPS.

Top level generic playbooks like `manage-users.yml` manage users with the
[cogini.users](https://galaxy.ansible.com/cogini/users) role.


Following is an example playbook used to provision an AMI, `playbooks/$APP/packer-$COMP.yml`:

```yaml
- name: Install base
  hosts: '*'
  become: true
  vars:
    app_name: foo
    comp: app
    tools_other_packages:
      - chrony
      # Parse cloud-init
      - jq
      # Sync config from S3
      - awscli
  vars_files:
    - vars/{{ app_name }}/{{ env }}/common.yml
    - vars/{{ app_name }}/{{ env }}/app.yml
    - vars/{{ app_name }}/{{ env }}/ses.yml
    - vars/{{ app_name }}/{{ env }}/ses.vault.yml
    - vars/foo/{{ env }}/elixir-release.yml
  roles:
    - common-minimal
    - tools-other
    - cogini.users
    - iptables
    - iptables-http
    - codedeploy-agent

    - cronic
    - postfix-sender
    - mesaguy.prometheus
    - postgres-client
    - cogini.elixir-release
```

It loads its config using `vars_files` from the vars directory, then runs a
series of roles.

## Storing secrets

For smaller projects, we store application secrets in the [Ansible
Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html). The
vault is a mechanism for encrypting secrets so that they can be stored in
configuration files which are checked into source control.  The `vault.key`
file has the encryption key for the project.

For larger projects or ones with more strigent security requirements,
we use tools like [AWS Systems Manager Parameter
Store]( https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html).

To generate an Ansible vault key:

```shell
pwgen -s 16
```

Put it in `ansible/vault.key`. Keep it secret, and make sure it's not checked into git.

`playbooks` contains common and app-specific playbooks.

Generate secrets and put them in Ansible config using `ansible-vault`.
See [Managing app secrets with Ansible](https://www.cogini.com/blog/managing-app-secrets-with-ansible/)

### Running Ansible

Before running Ansible, activate the virtualenv if you are using one.

```shell
source ~/.virtualenvs/deploy/bin/activate
```

Load the environment vars from `set_env.sh`.

Manually set `APP` and `ENV` environment vars depending on what you are working
on:

```shell
export ENV=dev
source set_env.sh
```

### Roles

Roles are reusable libraries of commands.

Our internal roles are in the `roles` directory.

To the extent possible, roles should not contain application-specific variables.
Variables should be set in the inventory or vars loaded by playbooks.

Roles from [Ansible Galaxy](https://galaxy.ansible.com/) are in `roles.galaxy`.
We normally check galaxy roles into git to lock the versions and ensure
availability.  To install them from scratch, see `install_roles.yml`.
