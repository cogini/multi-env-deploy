# Installation

This document describes how to install tools such as Teraform, Ansible, and
Packer.

The simplest way to install on macOS is with [Homebrew](https://brew.sh/).
The disadvantage is that you are installing software globally on your machine,
and you can end up with version conflicts across different projects.

Because of this, we generally use [ASDF](https://asdf-vm.com/#/) to manage
dependencies, allowing each project have its own versions.

Python is needed to run Ansible, the AWS CLI and scripts which use boto.
You can use the Python which comes with MacOS or Python 2/3 from Homebrew.
We normally use ASDF to install Python 3, and we install Ansible and AWS CLI
using pip. See the [Ansible](http://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
and
[AWS](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
docs for other options.

For even more isolation, you can install Python libraries in a virtualenv.

## Install Homebrew

On macOS, first install [Homebrew](https://brew.sh/) .

## Install misc utils

```shell
brew install jq pwgen
```

## Install tools using Homebrew

```shell
brew install terraform
brew install terragrunt
brew install packer
```

Install Python dependencies, including ansible and awscli.
Change to the `ansible` directory and run:

```shell
python -m pip install -r requirements.txt
```

## Install ASDF

Follow the
[installation instructions](https://asdf-vm.com/#/core-manage-asdf-vm)
or use this
[script to install ASDF on MacOS](https://github.com/cogini/mix-deploy-example/blob/master/bin/build-install-asdf-macos).

After installing, log out of your shell and log back in to activate the scripts
in `~/.bashrc`.

ASDF looks at the `.tool-versions` file and automatically sets the
path to point to the specified versions.

## Install tools via ASDF

First install the plugins for the tools:

```shell
asdf plugin add terraform
asdf plugin add terragrunt
asdf plugin add packer
```

Install pacackages:

```shell
asdf install
```

## Install Python using ASDF

```shell
asdf plugin add python
asdf install
```

Install libraries into the ASDF version:

```shell
python -m pip install -r requirements.txt
```

When you use pip to install a module like Ansible that has executables, you
need to run `asdf reshim python` to put the binary in your path.

```shell
asdf reshim python
```

### Install Python libraries in virtualenv

To isolate the python libraries used by one project from another, you can
create a virtualenv, a private project-specific directory for python libraries.
This applies whether you are using ASDF or not.

In the `ansible` directory:

For Python 3.x:

```shell
# Create virtualenv
python3 -m venv ~/.virtualenvs/deploy

# Activate it
source ~/.virtualenvs/deploy/bin/activate

# Install libraries into it
python3 -m pip install -r requirements.txt
```

or for Python 2.x:

```shell
# Create virtualenv
virtualenv ~/.virtualenvs/deploy

# Activate it
source ~/.virtualenvs/deploy/bin/activate

# Install libraries into it
python -m pip install -r requirements.txt
```

Later, when running the commands, activate the virtual environment first, putting it
first on your path.

```shell
source ~/.virtualenvs/deploy/bin/activate
```
