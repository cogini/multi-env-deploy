# Terraform

[Terraform](https://www.terraform.io/) is used to create the AWS resources
used by the app.

It is a declarative configuration management tool, similar to AWS CloudFront,
but supporting multiple services, e.g. cloud providers like Azure as well as
many other services like CloudFlare.

With Terraform, you declare the structure and relationships between resources,
e.g. load balancers and auto scaling groups. You run Terraform, which compares
your configuration with the state of the system, then determines what changes
are needed to make them match.  You can first run "plan" to see what it would
change, then "apply" the changes.

We use [Terragrunt](https://terragrunt.gruntwork.io/), a wrapper
on Terraform which makes it easier to manage complex configurations.
The state of the system is stored in S3, using DynamoDB to lock the state,
allowing multiple users to work on it at the same time.

## Structure

Using Terragrunt, we separate the configuration into common modules,
app configuration and environment-specific variables.

Under the `terraform` directory is the `modules` directory and a directory for
each app, e.g. `foo`:

```
terraform
    modules
    foo
    bar
```

For many apps, the recommended Terragrunt structure in [Keep your Terraform
code DRY](https://terragrunt.gruntwork.io/use-cases/keep-your-terraform-code-dry/)
and [example](https://github.com/gruntwork-io/terragrunt-infrastructure-live-example)
works fine. It uses a directory hierarchy like:

```
aws-account
    env
        region
            resources
```
e.g.

```
dev
    stage
        us-east-1
            asg
```

In this case, we may have multiple prod environments in different regions, each
potentially with its own AWS account. We use a flatter structure combined with
environment vars which determine which config vars to load.

Under the app directory `foo` are:
```
terragrunt.hcl
common.yml
dev.yml
prod.yml
dev
prod
```

`terragrunt.hcl` is the top level config file. It loads configuration from YAML
files based on the environment, starting with common settings in `common.yml`
and overriding them based on the environment, e.g. `dev.yml`.

Configure `common.yml` to name the app you are building, e.g. `org`, `app`
and set the region it will run in.

Next configure the resources for the environment, e.g. `dev`.  Each resource
has a directory which defines its name and a `terragrunt.hcl` which sets
dependencies and variables.

Dirs for each environment define which modules will be used.
For example, this defines a single web app ASG behind a public load balancer,
SSL cert, Route53 domain, RDS database, CodePipeline building in a custom
container image, deploying with CodeDeploy, using KMS encryption keys:

```
acm-public
asg-app
codedeploy-app
codedeploy-deployment-app-asg
codepipeline-app
ecr-build-app
iam-codepipeline
iam-codepipeline-app
iam-instance-profile-app
iam-s3-request-logs
kms
launch-template-app
lb-public
rds-app
route53-delegation-set
route53-public
route53-public-www
s3-app
s3-codepipeline-app
s3-request-logs
sg-app-private
sg-db
sg-lb-public
sns-codedeploy-app
target-group-default
vpc
```

## Naming convention

The directory name is flexible, you can use whatever you like. Our naming
convention is to use the AWS resource type plus a component suffix, e.g.
`asg-api` for an autoscaling group for handling API requests.

This makes it straightforward to define multiple front end or worker components
or customize modules when necessary. Simply make a copy of the code and reference
it by name. This loose coupling is a key advantage of Terraform over
CloudFormation. When CloudFormation config gets large, it becomes hard to
manage and extend.

The Terraform code under `modules` generates default names based on `org`, `app`,
`env`, and `comp`. You can generally override names to match an existing
system, though, and import existing resources if necessary.

The naming convention for Terraform modules is that an "app" is something that
receives web requests, and a "worker" is a headless component that runs
background processes. The `foo` example names resources the same way, `app` and
`worker`, but it doesn't have to be that way. A more complex system might name
components `public`, `admin`, `api`, etc.

## Resources

Create resources by making a directory under the app env, e.g.
`terraform/foo/dev/asg-app`.  The `terragrunt.hcl` file configures the
resource and specifies its relationship to other resources.
To add another resource, create a directory, e.g. `asg-api`.

The `asg-api` config would be as follows:

```terraform
terraform {
  source = "${get_terragrunt_dir()}/../../../modules//asg"
}
dependency "vpc" {
  config_path = "../vpc"
}
dependency "lt" {
  config_path = "../launch-template-api"
}
dependency "tg" {
  config_path = "../target-group-api"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "api"

  min_size = 1
  max_size = 3
  desired_capacity = 1

  wait_for_capacity_timeout = "2m"
  # Wait for this number of healthy instances in load balancer
  wait_for_elb_capacity = 1

  health_check_grace_period = 30
  health_check_type = "ELB"

  # wait_for_capacity_timeout = "0"
  # health_check_type = "EC2"

  target_group_arns = [dependency.tg.outputs.arn]

  subnets = dependency.vpc.outputs.subnets["private"]

  launch_template_id = dependency.lt.outputs.launch_template_id
  launch_template_version = "$Latest" # $Latest, or $Default

  spot_max_price = ""
  on_demand_base_capacity = 0
  on_demand_percentage_above_base_capacity = 0
  override_instance_types = ["t3a.nano", "t3.nano"]
}
```

The `source` identifies the Terraform code, in this case `modules/asg`.
`dependency` lines reference other resources. Resources have input and
output variables, defined in `variables.tf` and `outputs.tf`.

The `inputs` section variables for the resource, e.g. AMI and instance type,
ASG size and health check parameters. After creating a resource, Terraform
stores the outputs in the state, which we can then use as inputs for other
modules.

The configuration for `dev` is normally roughly the same as `prod`, but with
e.g. smaller instances. It's possible, however, to have different structure as
needed. For example, you could give each developer their own ec2 instance which
shares a common dev db. In prod, it would use an ASG.

## Set environment vars

`set_env.sh` sets environment vars that configure Terraform for the app and
environment. Copy the file from the root into the app directory, e.g.
`terraform/foo`.  Before running Terraform, set up the environment:

```shell
export ENV=dev
source set_env.sh
```

`secrets.sh` sets a small number of secrets needed to bootstrap the system.
Generally speaking, we keep secrets out of Terraform, using the Ansible vault
or
[AWS SSM Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html),
but we need a few things for initial bootstrapping, e.g. creating the master
RDS database password. Load the secrets when you are working with those
resources.

```shell
source secrets.sh
````

## Managing state

Terragrunt has low level utilities for manipulating the state.

This lets you import existing assets or delete them, e.g.:

    terragrunt import 'aws_s3_bucket.buckets["assets"]' cogini-foo-dev-app-assets

During execution, Terragrunt uses DynamoDB to lock the system, preventing
simultaneous updates. Sometimes if you interrupt execution, the lock will not
get cleared. Edit DynamoDB via the AWS Console, deleting the line manually.
