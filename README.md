## How to use DigitalOcean Blueprints

### Install Terraform

Head to the [Terraform install page](https://developer.hashicorp.com/terraform/downloads) 
and follow the instructions for your platform. 

You can validate your local Terraform installation by running:
```shell
$ terraform -v 
Terraform v1.5.7
...
```

### Create DigitalOcean API token
Head to the [Applications & API](https://cloud.digitalocean.com/account/api/tokens) page 
and create new personal access token (PAT) by clicking the _**Generate New Token**_ button. 
Make sure to check **_Write_** scope for the token, as Terraform needs it to create new resources. 
After creating the token, make sure to save it as it disappears forever if you close the page. 
If you lost the token, delete it and create a new one.

### Set up a blueprint

Clone this repository to the machine where Terraform is installed:
```shell
$ git clone https://github.com/digitalocean/marketplace-blueprints.git
```

Head to the blueprint you are interested in, for this example we will use ELK:
```shell
$ cd marketplace-blueprints/blueprints/elk/
```

#### Define your variables

Edit `variables.tf` file and specify your API token like this:
```terraform
variable "do_token" {
  default = "dop_v1_your_beautiful_token_here"
}
```

**(Optional but Recommended)** Use SSH keys to deploy your Droplets instead of passwords. You can retrieve your list of SSH Key IDs using [doctl](https://docs.digitalocean.com/reference/doctl/how-to/install/).

Retrieve your SSH Key IDs:

```shell
doctl compute ssh-key list
```

Specify which SSH keys to use:
```terraform
variable "ssh_key_ids" {
  default = [123, 456, 789] # Replace these numbers with actual SSH key IDs
  type = list(number)
}
```

**(Optional but Recommended)** Specify the [region](https://docs.digitalocean.com/products/platform/availability-matrix/#available-datacenters) you want your Droplets to deploy:

```terraform
variable "region" {
  default = "nyc3"
}
```

We are almost there, now initialize the Terraform project by running:
```shell
$ terraform init
```

Finally, after project is initialized, run the Terraform apply to spin the blueprint:
```shell
$ terraform apply
```

It can take few minutes to spin the droplets
and some blueprints require extra time after the creation to finish the configuration.

# Marketplace Blueprints



This repository contains blueprints for Solution Stacks applications listed in our Marketplace.

Blueprint is the Terraform-based configuration and source code DigitalOcean uses to create Solution Stacks applications.

- Docs
- Blueprint [template](./template)
- Blueprint [generator](./scripts/generate-blueprint.sh)
- Blueprint [examples](./examples)

## How to create and publish your application
Check out our [contributing](./docs/CONTRIBUTING.md) guide to learn how to create and publish your blueprint!
