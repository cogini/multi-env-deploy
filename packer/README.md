# Packer

[Packer](https://www.packer.io/) is used to build AMI images.
It starts a new EC2 instance, runs shell and Ansible to configure
it, then turns it into an image which is used to start instances in an ASG.

## Structure

The Packer configuration is separated into files in the `builder`
directory and app specific files under e.g. the `foo` directory.

The Packer config files are generic, taking configuration from environment
vars. There are two files, one for Ubuntu (`builder/build_ubuntu.json`) and one
for CentOS (`builder/build_centos.json`). The files are generated from YAML
versions, e.g. `builder/build_ubuntu.yml`. If you make a change, run `make` to
generate the JSON file.

The configuration is driven by environment vars. First are the `ORG/APP/ENV`
vars set by the `set_env.sh` script in the root directory. Next, specific vars
are set for the app component in e.g. `foo/dev/build_app.sh`. Then defaults
are set by `builder/build.sh`, which calls packer to build the image.

## Configuration

First create the build script for the component. For example,
`foo/dev/build_app.sh` builds the AMI for the `app` component of the `foo` app
running in the `dev` environment.

At a minimum, you need to set the `COMP` and `DISTRO`:

```shell
export COMP="${COMP:-app}"
export DISTRO=ubuntu
```

For Ubuntu, Packer will look up the latest 18.04 minimal AMI to use as a base.

```yaml
source_ami_filter:
  filters:
    virtualization-type: hvm
    name: ubuntu-minimal/images/hvm-ssd/ubuntu-bionic*"
    root-device-type: ebs
  owners: ["099720109477"]
  most_recent: true
```

You can override these by setting environment vars, e.g.:

```shell
export AWS_AMI=ami-000daa3e36cc6a9c1
```

This command gives the available AMIs:

```shell
aws ec2 describe-images --owner 099720109477 --region $AWS_REGION \
    --filters "Name=name,Values=ubuntu-minimal/images/hvm-ssd/ubuntu-bionic*" \
    --query 'sort_by(Images, &CreationDate)[-1].{Name: Name, ImageId: ImageId, CreationDate: CreationDate}'
```

It will use the VPC tagged with "app=$APP" and build in the subnet with name "public".

```shell
export AWS_VPC=vpc-0f5694ff9558c49f2
export AWS_SUBNET=subnet-0ea5095512e62856d
```

You can get variables from Terraform by e.g. going to
`terraform/foo/dev/vpc` and running `terragrunt output`:

    vpc_id = vpc-0f5694ff9558c49f2

    subnets = {
      "public" = [
        "subnet-0ea5095512e62856d",
        "subnet-044e73199b51a0357",
      ]
      ...
    }

See `builder/build.sh` for details on the available environment vars.

## Ansible

The Packer shell builder does the minimum needed to install Ansible, then
calls the Ansible builder to do the rest of the install.
By default, it calls the `ansible/playbooks/$APP/packer-$COMP.yml` playbook.

The structure generally follows the approach in "[Setting Ansible variables
based on the environment](https://www.cogini.com/blog/setting-ansible-variables-based-on-the-environment/)".

It loads configuration from the Ansible inventory using dynamic groups
based on tags on the instances, `app=$APP`, `env=$ENV` and `comp=$COMP`.
This will e.g. read vars from `ansible/inventory/group_vars/all`
and `ansible/inventory/group_vars/tag_app_foo/`.

The playbook will then explicitly load variables under `ansible/vars`, e.g. `ansible/vars/foo/dev/app.yml`.
It copies the playbook into the instance and runs it locally, so the
`vars_files` relative paths to include vars files are different from playbooks
which are run on the local machine.

Ansible doesn't have a good priority between different group variables, so it's
best to set variables in only one place. It's better to use the explicit vars
except for things that are truly common to all components.

Packer passes the vault key to the instance so that it can access secrets.
Generally speaking, it's better not to put secrets in AMIs, they should
be loaded at launch time from e.g. S3 or AWS SSM Parameter Store.

## Building

First load the environment vars using `set_env.sh` in the root directory.

```shell
export ENV=dev
source set_env.sh
```

Next run the script to build the AMI:

```shell
foo/dev/build_app.sh
```

This launches an EC2 instance in the public VPC subnet and configures it.

The result is an AMI:

    ==> Builds finished. The artifacts of successful builds are:
    --> amazon-ebs: AMIs were created:
    ap-northeast-1: ami-026475e7ed8dde60d

Put the AMI id into e.g. the `image_id` var in
`terraform/foo/dev/launch-template-app/terragrunt.hcl`.

## Encryption

Packer can encrypt the base AMI. Set `export AWS_ENCRYPT_BOOT=true` and it will
use the default KMS key. Set a specific KMS key using `AWS_KMS_KEY_ID`.
