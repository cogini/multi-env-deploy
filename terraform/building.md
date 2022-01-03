# Building

It's tempting to look at a system in terms of automation, whether it is
possible to run a single command and build everything. Terraform modules
specify their dependencies, so theoretically you can just build a whole
environment at once:

    terragrunt plan-all --terragrunt-working-dir "$ENV"
    terragrunt apply-all --terragrunt-working-dir "$ENV"

The reality, however, is that it takes quite a lot of iterative work to
bring up a complex app. We also only bring up an app once, but maintain it over
time, and we need to optimize for that.

We need to be able to evolve the running system incrementally. For example,
first set it up on a standalone EC2 instance talking to RDS. Next set up the
build pipeline. After that's working, set it up in an ASG behind the load
balancer. It's easier to configure and build each resource one by one, as it
makes it easier to debug.

When building a new system, sometimes we want to delete things and rebuild from
scratch. In production, however, we can't delete the resources that that hold
user data, such as S3 buckets and RDS databases.

Because of this, we structure the Terraform modules in layers, starting with the
data and things that don't change, then things with a lot of dependencies (e.g.
vpc), then app instances, then things that we can delete without affecting
users. This way we can delete back to the data, then rebuild it.

Following is the recommended order to bring up resources with description of
what they do.

## DNS and certs

In a full featured app, we might have a public website with marketing
materials, an app back end, and maybe more servers for e.g. API.
We might also use a different domain to host static assets in a CDN.

We generally use a different domain for each environment, e.g. `example.com`
for prod and `example.info` for dev. This makes it easy for us to keep
consistent hosts for services, e.g. api.example.com and support per-customer
subdomains.

In this example we assume that the wildcard domain (e.g. `*.example.com`) points
to the load balancer, which directs traffic to the primary app by default, e.g.
Ruby on Rails.

We can also can use a static site generator to manage the public website, putting the
resulting files in an S3 bucket which is served by CloudFront CDN.  In this
example, the `public-web` resources do this. We then set up DNS entries
to point `www.example.com` and the bare domain to CloudFront.

We can also run a separate server like WordPress for the public website.
Additional servers running behind the same load balancer each get their own
Target Group, and a routing rule directs traffic based on subdomain or URL.
This lets you use e.g. Elixir to handle API traffic and put it on
`api.example.com` or `example.com/api`.

We normally use Amazon Certificate Manager to handle SSL certs. They are free,
but only if you are using a load balancer or CloudFront. Otherwise you can use
a cert from an external provider or Let's Encrypt.

Create a delegation set:

    route53-delegation-set

This is a set of name servers which will be used when creating a zone. It's
useful to create it separately from the zone, as you can then specify the name
servers for the domain in the registrar and they will stay the same even if you
delete the Route53 zone and create it again.

Update the DNS registrar for the domain to use these name servers.

Create the Route53 zone for the public domain:

    route53-public

Create Route53 alias records for public DNS, i.e. `www.example.com`, pointing
to either load balancer or CloudFront.

    route53-public-www

The `ec2-app` module can also optionally set up public DNS records for
standalone EC2 instances.

Create a SSL cert for the public domain using ACM:

    acm-public

CloudFront certs need to be in AWS region `us-east-1`. If your resources are in
a different region and you are not using a separate CDN domain, create a second
cert for the public domain for CloudFront in that region:

    acm-public-cloudfront

AWS has a surprisingly low limit (one or two dozen) on the number of certs
*created* per year (not total in your account), so it's better not to delete
them and recreate them.

If you are using a separate CDN domain (optional), set up DNS and create an SSL
cert for the domain, e.g. `route53-cdn` and `acm-cdn`.

## Encryption

We do a lot of work with health care and financial systems, so this
framework supports encrypting everything. You can use the default AWS keys, or
create your own and pass the id as a parameter to various components.

Create a custom encryption key (optional):

    kms

If you are using CloudFront signed URLs, generate CloudFront keys as well.

## Data

In a standard app, you might have buckets for data, configuration,
JS/CSS assets, etc. Create S3 buckets for the app:

    s3-app

Create S3 buckets for building app with CodePipeline and deploying with
CodeDeploy:

    s3-codepipeline-app

Create bucket for Load Balancer and CloudFront logs:

    s3-request-logs

Create buckets for worker:

    s3-worker

Create buckets for building worker with CodePipeline:

    s3-codepipeline-worker

Create buckets for hosting static public website with CloudFront:

    s3-public-web

Create buckets for building static public website with CodePipeline:

    s3-codepipeline-public-web

## IAM roles/instance profiles

IAM instance profiles control what resources components can access at runtime.

Create role and IAM instance profile for app:

    iam-instance-profile-app

Create IAM instance profile for worker:

    iam-instance-profile-worker

Add Lambda service roles for public web:

    iam-lambda-edge

If using bastion or devops instances, create role and instance profile (optional):

    iam-instance-profile-devops
    iam-instance-profile-bastion
    iam-instance-profile-prometheus

### CodePipeline

Create common service roles:

    iam-codepipeline

These service roles give CodePipeline the basic rights to run in the account.

Give service roles access to S3 buckets for app component:

    iam-codepipeline-app

This gives CodeBuild access to specific resources, e.g. to write app JS/CSS
assets to an S3 bucket served by CloudFront.

Give service roles access to S3 buckets for worker component:

    iam-codepipeline-worker

Give service roles access to S3 buckets for public web:

    iam-codepipeline-public-web

## VPC

Create VPC:

    vpc

Create a [EC2 NAT instance](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html),
cheaper to run than NAT Gateway:

    nat

Create security groups:

    # App running on an EC2 instance in the public subnet
    sg-app-public

    # App running in an ASG in the private subnet
    sg-app-private

    # RDS database. For a more complex app, name it sg-rds-app
    sg-db

    # Load balancer in public subnet
    sg-lb-public

    # Worker component in private subnet
    sg-worker

    # CodeBuild instances. This SG gives them rights to talk to e.g. RDS
    sg-build-app
    sg-build-worker

    sg-bastion
    sg-devops
    sg-prometheus

## SNS

Create SNS topics:

    sns-codedeploy-app

## RDS

Generate a master RDS password.

    pwgen -s 16

Put it in Ansible (see [Managing app secrets with Ansible](https://www.cogini.com/blog/managing-app-secrets-with-ansible/)):

    echo -n XXX | ansible-vault encrypt_string --stdin-name 'db_master_pass'

Put it in `secrets.sh`.

    source secrets.sh

Create RDS database for app component:

    rds-app

## Load Balancer

Give ALB service write access to request logs S3 bucket:

    iam-s3-request-logs

Create public Application Load Balancer:

    target-group-default
    lb-public

## App

Build a custom AMI with Packer.

Create standalone EC2 instance(s) for app:

    ec2-app

and/or

Create ASG for app behind load balancer:

    launch-template-app
    asg-app

Set up app database user and password with `ansible/playbooks/foo/bootstrap-db-pg.yml`.
Copy app config to S3 bucket with `ansible/playbooks/foo/config-app.yml` and
`ansible/playbooks/foo/config-app-https.yml`.

## Build and deploy component

You can build using the default AWS images, but creating a custom image at the
beginning will save you a lot of time waiting as you iterate on getting your system
running. See [Extending AWS CodeBuild with Custom Build Environments](https://aws.amazon.com/blogs/devops/extending-aws-codebuild-with-custom-build-environments/)
and [Speeding up AWS CodeBuild with Custom Build Environments](https://stephenmann.io/post/speeding-up-aws-codebuild-using-custom-build-containers/)

You can also run CodeBuild on your local machine. This speeds things up even
more, though it has differences from the real environment. See
[Announcing Local Build Support for AWS CodeBuild](https://aws.amazon.com/blogs/devops/announcing-local-build-support-for-aws-codebuild/)
and [Test and Debug Locally with the CodeBuild Agent](https://docs.aws.amazon.com/codebuild/latest/userguide/use-codebuild-agent.html).

Create Elastic Container Registry for custom CodeBuild image:

    ecr-build-app

Create custom build image and push it to registry:

    export REPOSITORY_URL=$(terragrunt output repository_url)
    aws ecr get-login --no-include-email | bash
    pushd ~/work/mix-deploy-example
    docker build -t $REPOSITORY_URL -f build/docker/Dockerfile .
    docker push $REPOSITORY_URL
    popd

Create CodeDeploy "app" for component:

    codedeploy-app

Create CodeDeploy deployment for app component running in ASG behind a Load Balancer:

    codedeploy-deployment-app-asg

Create CodeDeploy deployment for app component running in EC2 instances:

    codedeploy-deployment-app-ec2

Generate GitHub access token:

1. While logged into GitHub, click your profile photo in the top right, then click Settings.
2. On the left, click Developer settings.
3. On the left, click Personal access tokens.
4. Click Generate new token and enter AWSCodePipeline for the name.
5. For permissions, select repo.
6. Click Generate token.
7. Put the token in `secrets.sh`

Create CodePipeline for app component:

    source secrets.sh # for GITHUB_TOKEN
    codepipeline-app

## Public web from static site in CloudFront

Set up lambda edge functions for CloudFront:

    lambda-edge

Create CloudFront distribution for public website:

    cloudfront-public-web

Create CodePipeline to build and deploy:

    codepipeline-public-web

## Public Web

Create Route53 alias records for public DNS, i.e. `www.example.com`, pointing
to either CloudFront.

    route53-public-www

The `ec2-app` module can also optionally set up public DNS records for
standalone EC2 instances.

## Bastion (optional)

Create bastion EC2 instance(s) in VPC public subnet, allowing SSH access to
machines inside VPC private subnet:

    ec2-bastion

## DevOps (optional)

Create devops EC2 instance inside VPC private subnet for admin and build operations:

    ec2-devops

Set up instance:

    ansible-playbook -v -i foo-dev-devops, playbooks/foo/devops.yml

## Prometheus (optional)

Create Prometheus instance in public subnet:

    ec2-prometheus

## Worker

Standalone EC2 instance:

    ec2-worker

and/or

ASG without a load balancer:

    asg-worker

Create Elastic Container Registry for custom CodeBuild image:

    ecr-build-worker

Create custom build image and push it to registry:

    export REPOSITORY_URL=$(terragrunt output repository_url --terragrunt-working-dir "$ENV/ecr-build-worker")
    aws ecr get-login --no-include-email | bash
    pushd ~/work/mix-deploy-example
    docker build -t $REPOSITORY_URL -f docker/Dockerfile.build .
    docker push $REPOSITORY_URL
    popd

Create CodeDeploy "app" for component:

    codedeploy-worker

Create CodeDeploy deployment for worker component running in EC2 instances:

    codedeploy-deployment-worker-ec2

Create CodeDeploy deployment for worker component running in ASG:

    codedeploy-deployment-worker-asg

Create CodePipeline for worker component:

    codepipeline-worker

## App

Create CloudFront distribution for app assets, e.g. CSS/JS:

    cloudfront-app-assets

## SES

Verify a domain using DNS for sending mail via SES:

    route53-ses

Create an IAM user with rights to send email via SES.

    iam-ses-app

## Additional app components

Create a non-default target group:

    target-group-app

## CodeCommit

If you are using something other than GitHub, e.g. Gitlab, then you need to
create a mirror repo with CodeCommit inside AWS.

    codecommit-repo-bounce
    codecommit-repo-log-elasticsearch
    iam-codecommit-bounce
    iam-codecommit-log-elasticsearch
    iam-codecommit-user-mirror-bounce
    iam-codecommit-user-mirror-log-elasticsearch

## Elasticsearch

Create Elasticsearch domain:

    sg-elasticsearch-app
    elasticsearch-app
    iam-elasticsearch-app

## Elasticache

    sg-redis-app
    redis-app

    sg-memcached-app
    memcached-app

## ECS

* iam-ecs
    Import if it already exists
* iam-ecs-task-execution
* iam-ecs-task-role-app
* ecs-cluster
* ecr-app

    export REGISTRY=$(terragrunt output registry_id)
    export REPO_URL=$(terragrunt output repository_url)
    # aws ecr get-login --no-include-email | bash
    aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $REPO_URL
    pushd ~/work/phoenix_container_example
    DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build -t $REPO_URL -f deploy/Dockerfile.alpine .
    docker push $REPO_URL
    popd

* ecr-build-app-ecs

    cd terraform/foo/dev/ecr-build-app-ecs
    export REGISTRY=$(terragrunt output registry_id)
    export REPO_URL=$(terragrunt output repository_url)
    # aws ecr get-login --no-include-email | bash
    aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $REPO_URL
    pushd ~/work/phoenix_container_example
    # DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build -t $REPO_URL -f deploy/Dockerfile.codebuild .
    # docker push $REPO_URL
    DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --push -t $REPO_URL -f deploy/Dockerfile.codebuild .
    popd

    https://github.com/aws/aws-codebuild-docker-images/blob/master/ubuntu/standard/4.0/Dockerfile

* ecs-task-app

* target-group-app-ecs-1
* target-group-app-ecs-2

* ecs-service-app

* codedeploy-app-ecs
* codedeploy-deployment-app-ecs
* codepipeline-app-ecs

* route53-public-lb-app-ecs


# TODO

* Migration issues
    - vpc endpoints
