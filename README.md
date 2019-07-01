# Terraform & Packer for Kali Linux EC2 instance

## Description

Create a Kali Linux EC2 instance by utilizing [Packer](http://packer.io/) by using the official [Kali Linux AMI](https://aws.amazon.com/marketplace/pp/B01M26MMTT/) and and `apt-get dist-upgrade` to be up-to-date with the Kali Linux [Rolling Release](https://www.kali.org/kali-linux-releases/).

If you don't want to run Packer, Terraform uses the default Kali Linux AMI `ami-10e00b6d` based on **Kali Linux 2018.3a**. Please keep in mind that this is outdated and you have to update yourself to the current Rolling Release (`apt-get update && apt-get dist-upgrade`).

## IMPORTANT

Before running the `packer build`, you have to accept the terms and conditions of the Kali Linux AMI (this is an requirement of the AWS Marketplace):

https://aws.amazon.com/marketplace/pp/B01M26MMTT/

or (this will shown to you when you run this Terraform before accepting the terms):

https://aws.amazon.com/marketplace/pp?sku=89bab4k3h9x4rkojcm2tj8j4l

* Click on _"Continue to Subscribe"_
* Then _"Accept Terms"_

and no, this Kali AMI has ***no costs*** (it's FREE!) - the price shown to you on the AWS Marketplace is for the calculated EC2 instance type usage.


## Usage

### Clone the repository

`git clone git@github.com:hajowieland/terraform-kali-linux.git` (when using SSH)

### Packer: Build your custom AMI

`packer build packer.json`

Note down the AMI ID at the end:

```
...
==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:
eu-central-1: ami-10e00b6d
```

### Terraform: Customize your AWS EC2 instance configuration

By default, Terraform uses this configuration if you don't create an AMI with Packer and leave everything as is:

* Creates a **new VPC** with CIDR range `10.23.0.0/16`
* Create **new Subnet** with CIDR range `10.23.1.0/24`
* Uses `IPv4` & `IPv6`
* Creates **new AWS Key pair** from your `~/.ssh/id_rsa.pub` public key
* Creates EC2 instance with instance type `t2.medium` (2 vCPU, 4.0 GB Memory)
* EC2 instance uses default Kali Linux AMI `ami-10e00b6d` (based on **Kali Linux 2018.3a** so you have to update yourself)


### Links

If you want to completely build your own Kali Linux, you can use the official [kali-cloud-build](https://gitlab.com/kalilinux/build-scripts/kali-cloud-build) tools.
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| packer\_ami | Packer AMI ID to use for EC2 instance (NOTE: run `packer buidl packer.json` and use the generated AMI ID here) | string | `"ami-10e00b6d"` | yes |
| aws\_profile | AWS cli profile | string | `"default"` | no |
| aws\_region | AWS region | string | `"eu-central-1"` | no |
| create\_vpc | Create new VPC (e.g. `true` or `false`) - Please set to false when setting an existing vpc_id above - NOTE: no doublequotes around the true or false | string | `"true"` | no |
| ec2\_instance\_type | EC2 instance type (e.g. `t2.medium` or `t2.small`) | string | `"t2.medium"` | no |
| public\_key\_path | Path to your SSH public key (e.g. `~/.ssh/id_rsa.pub`) | string | `"~/.ssh/id_rsa.pub"` | no |
| ssh\_key\_pair\_name | AWS Key pair name of existing SSH Key pair on AWS (e.g. `my-key`) | string | `""` | no |
| subnet\_cidr\_block | The CIDR block to use for the new subnet (e.g. `10.23.0.0/24` or `172.31.0.0/20`) - Must be in range of VPC CIDR | string | `"10.23.1.0/24"` | no |
| subnet\_id | Use an existting Subnet in an existing VPC (please set create_vpc to false when using this) | string | `""` | no |
| use\_ipv4only | Use IPv4 only (e.g. `true` or `false`) - Please set use_ipv6 to false when enabling this - NOTE: no doublequotes around the true or false | string | `"false"` | no |
| use\_ipv6 | Use IPv4 AND IPv6 (e.g. `true` or `false`) - NOTE: no doublequotes around the true or false | string | `"true"` | no |
| vpc\_cidr | VPC CIDR block for new AWS VPC (e.g. `10.23.0.0/16` or `172.31.0.0/16`) - The Subnet CIDR must match this VPC CIDR | string | `"10.23.0.0/16"` | no |
| vpc\_id | Use an existing VPC (please set create_vpc to false when using this) | string | `""` | no |

### Outputs

| Name | Description |
|------|-------------|
| public\_ip | Public IPv4 address of Kali EC2 instance |



