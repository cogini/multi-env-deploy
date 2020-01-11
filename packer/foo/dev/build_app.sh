#!/usr/bin/env bash

# Build AMI for app component

export COMP="${COMP:-app}"

export DISTRO=ubuntu

# Set vars here to override defaults in builder/build.sh
export AWS_ENCRYPT_BOOT=true
# export AWS_KMS_KEY_ID="0093d271-e785-47c1-9691-dbc9f4133dbd"

case $DISTRO in
    ubuntu)
        # Packer looks up latest ubuntu-minimal/images/hvm-ssd/ubuntu-bionic* by default
        # You can specify the AMI here

        # Ubuntu 8.04 minimal
        # export AWS_AMI=ami-000daa3e36cc6a9c1

        # aws ec2 describe-images --owner 099720109477 --region $AWS_REGION \
        #     --filters "Name=name,Values=ubuntu-minimal/images/hvm-ssd/ubuntu-bionic*" \
        #     --query 'sort_by(Images, &CreationDate)[-1].{Name: Name, ImageId: ImageId, CreationDate: CreationDate}'
        ;;
    centos)
        # CentOS 7
        export AWS_AMI=ami-8e8847f1
        ;;
    *)
        echo "Invalid DISTRO"
        exit 1
esac

CURDIR="$PWD"
BINDIR=$(dirname "$0")
cd "$BINDIR"; BINDIR="$PWD"; cd "$CURDIR"

$BINDIR/../../builder/build.sh
