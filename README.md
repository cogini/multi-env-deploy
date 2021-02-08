This is an example of how to deploy a real-world complex web app to AWS.

Full-featured apps in languages like Ruby on Rails have multiple components,
e.g. web front end, background job handler, periodic jobs, maybe a separate
server to handle API traffic or web sockets. They use a relational database,
Redis or Memcached, Elasticsearch, CDN for static assets, SSL, S3 buckets,
encryption.  They need logging, metrics, and alerting.

They run in an autoscaling group or ECS and use a CI/CD pipeline to handle
blue/green deployment. They need to run in multiple environments: dev, staging,
prod, demo, with slight differences for each. They have some weird things to
integrate with partners.

This framework handles all that :-)

It's built in in a modular way using Terraform, Ansible and Packer. We have
used it to deploy multiple complex apps, so it handles many things that
you will need, but it's also flexible enough to be tweaked when necessary for
special requirements. It represents months of work.

The blog post
[Deploying complex apps to AWS with Terraform, Ansible, and Packer](https://www.cogini.com/blog/deploying-complex-apps-to-aws-with-terraform-ansible-and-packer/)
gives an example.

# Scenarios

These modules cover the following scenarios:

## EC2 + RDS

* Virtual private cloud (VPC) with public, private and database subnets
* App runs in EC2 instance(s) in the public subnet
* RDS database
* App data stored in S3
* Route53 DNS with health checks directs traffic to app instances

This is good for a simple app, and is also a stepping stone when deploying
more complex apps. EC2 instances can be used for development or as a canary.
See the [AWS docs](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)
for overview.

## CloudFront for assets

Store app assets like JavaScript and CSS in CloudFront for performance

## CodePipeline for CI/CD

Whenever code changes, pull from git, build in CodeBuild, run tests and deploy
automatically using CodeDeploy. Run tests against resources such
as RDS or Redis. Supports both GitHub and CodeCommit.

## Auto Scaling Group and Load Balancer

* App runs in an ASG in the private VPC subnet
* Blue/Green deployment
* SSL using Amazon Certificate Manager
* Spot instances to reduce cost
* Multiple deploy targets
* Manual approval process
* Notifications

## Containers running in ECS

* App is built in CodePipeline
* Deployed to ECS using CodeDeploy Blue/Green deployment

## Worker ASG

Worker runs background tasks in an ASG, with its own build and deploy pipeline.

## Multiple front end apps

Route traffic between web apps using the Load Balancer, e.g. separate
servers for API, customer admin, back end admin.

## S3 buckets

* Share data between apps using S3 buckets with access control
* Use signed URLs to handle protected user content

## Static website

Build the public website using a static site generator in CodeBuild, deploying
to CloudFront CDN. Use Lambda@Edge to rewrite URLs.

## Elasticache

Add Elasticache Redis or Memcached for app caching.

## Elasticsearch

Add Elasticsearch for the app.

## DevOps

Add a DevOps instance to handle deployment and management tasks.

## Bastion host

Add Bastion host to control access to servers in the private subnet.
Or use with AWS SSM Sessions.

## Prometheus metrics

Add Prometheus for application metrics and monitoring

## SES

Use SES for email.

# How it works

It uses [Terraform](https://www.terraform.io/) to create the infrastructure,
[Ansible](https://www.ansible.com/) and [Packer](https://www.packer.io/) to set
up instances and AMIs. It uses AWS CodePipeline/CodeBuild/CodeDeploy to build
and deploy code, running the app components in one or more autoscaling groups
running EC2 instances.

The base of the system is Terraform and [Terragrunt](https://github.com/gruntwork-io/terragrunt).
Common Terraform modules can be enabled according to the specific application
requirements. Similarly, it uses common Ansible playbooks which can be modified
for specific applications. If an app needs something special, we can easily add a
custom module for it.

We use the following terminology:

* Apps are under an `org`, or organization, e.g. a company. `org_unique` is
  a globally unique identifier, used to name e.g. S3 buckets

* An `env` is an environment, e.g. dev, stage, or prod. Each gets its own
  AWS account

* An `app` is a single shared set of data, potentially accessed by multiple
  front end interfaces and back end workers. Each app gets it's own VPC.
  A separate VPC, generally one per environment, handles logging and monitoring
  using ELK and Prometheus

* A `comp` is an application component

We have three standard types of components: web app, worker and cron.

**Web apps** process external client requests. Simple apps consist of only a single
web app, but complex apps may have more, e.g. an API server, admin interface or
instance per customer.

**Workers** handle asynchronous background processing driven by a job queue
such as Sidekiq, SQS or a Kafka stream. They make the front end more responsive
by offloading long running tasks. The number of worker instances in the ASG
depends on the load.

**Cron** servers handle timed batch workloads, e.g. periodic jobs. From a
provisioning perspective, there is not much difference between a worker and a
cron instance, except that cron instances are expected to always be running so
that they can schedule jobs.  Generally speaking, we prefer to move periodic
tasks to Lambda functions where possible.

We normally run application components in an auto scaling group, allowing
them to start and stop according to load. This also provides high availability,
as the ASG will start instances in a different availability zone if they die.
This makes it useful even if we normally only have one instance running.

Running in an ASG requires that instances start from a "template" image AMI and
be stateless, storing their data in S3 or RDS. We can also run components in
standalone EC2 instances, useful for development and earlier in the process of
migrating the app to the cloud.

We can also deploy the app to containers via ECS as part of the same system.
Everything is tied together with a common ALB, so it's just a question of
routing traffic.

When possible, we utilize managed AWS services such as RDS, ElastiCache, and
Elasticsearch. When managed services lack functionality, are immature or are
expensive at high load, we can run our own.

The system makes use of CloudFront to host application assets as well as static
content websites or "JAM stack" apps using tools like
[Gatsby](https://www.gatsbyjs.org/).

We deploy the application using AWS CodeDeploy using a blue/green deployment
strategy. The CodeDeploy releases can be built using CodePipeline or a DevOps
EC2 instance.

By default we use Route53 for DNS and ACM for certificates, though it can
work with external DNS, certs and other CDNs like CloudFlare.

## Getting started

* Install tools and libraries, see [doc/install.md](doc/install.md)
* Configure the system, see [doc/config.md](doc/config.md)
* Create infrastructure with Terraform, see [terraform/README.md](terraform/README.md)
  and [terraform/building.md](terraform/building.md)
* Create configuration with Ansible, see [ansible/README.md](ansible/README.md)
* Create AMIs with Ansible and Packer, see [packer/README.md](packer/README.md)
* Have fun!

[Contact Us](https://www.cogini.com/contact/) if you would like help deploying
your complex app.
