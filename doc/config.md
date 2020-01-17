# Configuration

This describes common configuration settings and general information.

## Environment vars

Configure the environment using `set_env.sh`. See the `set_env.sh.sample` in
the project root directory. When building multiple apps from the same source,
we normally copy this to e.g. `terraform/foo`.

These scripts can work with multiple apps and environments in the same repo.
Environment variables vars control how they run:

* `ORG`: organization that the app runs under, e.g. company or project
* `APP`: specific app, e.g. `foo`
* `ENV`: environment, e.g. `dev`, `stage`, `prod`, `demo`
* `OWNER`: resource creator or billing unit, used to tag resources

## Secrets

Most application secrets such as passwords and keys are stored in Ansible vault
or AWS SSM Parameter Store. The Ansible vault stores variables in encrypted files,
automatically decrypting them when needed. This allows them to be checked into
git and shared with admins who have the key file. See `ansible/README.md` for
details.

Terraform needs some passwords when setting up the system, specifically the
master RDS database password and OAuth token used to talk to GitHub.
Set them in `secrets.sh` and source the file when working with those resources.

## AWS accounts

Following the [AWS Organizations](https://aws.amazon.com/organizations/) structure,
we use multiple AWS accounts: a master account for consolidated billing and
sub accounts for each environment (dev, prod). Simple organizations might
have two accounts, one for dev and one for prod, using one VPC per app + env.
Apps reqiring more security might make a separate account for each app + env.

It is possible to put multiple orgs and apps in one account, but these
scripts expect that each app + env gets its own VPC. This simplifies
the scripts by avoiding having too much configurability.

While you can set detailed permissions on the user creating resources,
these docs assume you are using IAM user with SuperUser permissions.

Create an IAM user along with access keys in each environment.
Add AWS credentials to `~/.aws/credentials`:

```text
[myorg-dev]
aws_access_key_id = xxx
aws_secret_access_key = yyy

[myorg-prod]
aws_access_key_id = xxx
aws_secret_access_key = yyy
```

The name of the profile should match the value set in `set_env.sh` env var
`AWS_PROFILE` org + env:

```shell
export AWS_PROFILE=$ORG-$ENV
```

or app + environment:

```shell
export AWS_PROFILE=$APP-$ENV
```

## EC2 key pair

The EC2 key pair is an ssh key which gives ssh access to EC2 instances. Treat
it like a root password. It's only used for initial setup or emergencies,
keep it somewhere safe and only give access to people who need it.

Create a key pair for each org + env or app + env:

```shell
aws ec2 create-key-pair --key-name "$ORG-$ENV" | jq '.KeyMaterial' --raw-output > "$ORG-$ENV.pem"
```

Put the file in `~/.ssh/`. It is mainly used by Ansible, see `ansible/ssh.config`.

See [the AWS docs](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-key-pair.html) for more info.

## Remote access

Interactive logins to servers is controled using individual user ssh keys or
[AWS SSM Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html).

Session Manager uses IAM roles to define who can connect to servers. You can
connect to servers in the private VPC subnet without opening up ssh access from
the outside.

With ssh, you can connect directly to servers in the public subnet or via a
bastion to internal servers. The
[cogini.users](https://galaxy.ansible.com/cogini/users) Ansible role manages
user access with ssh public keys. It can be used when
building AMIs or directly on running servers.

A typical use case would be in a relatively small, static organization. You can
configure it to give sudo access to your systems admins and tech leads and
access to the app user account to developers. You can then run it against the
bastion host to restrict access at the boundary, allowing you to revoke user
access in a single place. In larger organizations, using ssh certificates is
easier to manage.

Users can be specified by GitHub userid or put in the `playbooks/files` directory.
