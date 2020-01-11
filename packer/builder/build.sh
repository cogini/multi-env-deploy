#!/bin/bash

# Environment vars
# ORG
# ENV
# APP
# COMP
# DISTRO

# Packer looks up latest ubuntu-minimal/images/hvm-ssd/ubuntu-bionic* by default
# export AWS_AMI=ami-000daa3e36cc6a9c1

# AWS_REGION

export AWS_PROFILE="${AWS_PROFILE:-"$ORG-$ENV"}"
export AWS_INSTANCE_TYPE="${AWS_INSTANCE_TYPE:-t2.micro}"
export AWS_IAM_INSTANCE_PROFILE="${AWS_IAM_INSTANCE_PROFILE:-"$APP-$COMP"}"

# Looked up with tag "app=$APP" by default
# export AWS_VPC=vpc-0f5694ff9558c49f2

# Looked up with name "public" by default
# export AWS_SUBNET=subnet-0ea5095512e62856d

# export AWS_SECURITY_GROUP="$APP-$COMP"
# undefined by default, generally not needed

export AWS_ENCRYPT_BOOT="${AWS_ENCRYPT_BOOT:-false}"
# export AWS_KMS_KEY_ID="0093d271-e785-47c1-9691-dbc9f4133dbd"
# undefined by default, needed when using a custom KMS key

export ANSIBLE_PLAYBOOK_DIR=../ansible
export ANSIBLE_PLAYBOOK_FILE="$ANSIBLE_PLAYBOOK_DIR/playbooks/$APP/packer-$COMP.yml"
export ANSIBLE_GROUP_VARS_DIR="$ANSIBLE_PLAYBOOK_DIR/inventory/group_vars"
export ANSIBLE_EXTRA_ARGUMENTS="-v -D"
export ANSIBLE_EXTRA_VARS="env=$ENV"
# export ANSIBLE_EXTRA_VARS="env=$ENV ansible_python_interpreter=/usr/bin/python3"

CURDIR="$PWD"
BINDIR=$(dirname "$0")
cd "$BINDIR"; BINDIR="$PWD"; cd "$CURDIR"

ANSIBLE_VAULT_PASS=`cat $ANSIBLE_PLAYBOOK_DIR/vault.key` packer build "$BINDIR/build_${DISTRO}.json"
