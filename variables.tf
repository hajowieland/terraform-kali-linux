variable "aws_region" {
  description = "AWS region"
  default     = "eu-central-1"
}

variable "aws_profile" {
  description = "AWS cli profile"
  default     = "default"
}

variable "vpc_cidr" {
  description = "VPC CIDR block for newly created AWS VPC (e.g. `10.23.0.0/16` or `172.31.0.0/16`) - The Subnet CIDR below must match this VPC CIDR"
  default     = "10.23.0.0/16"
}

variable "subnet_cidr_block" {
  description = "The CIDR block to use for the newly created subnet (e.g. `10.23.0.0/24` or `172.31.0.0/20`) - Must be in range of VPC CIDR"
  default     = "10.23.1.0/24"
}

variable "ssh_key_pair_name" {
  description = "AWS Key pair name of existing SSH Key pair on AWS (e.g. `my-key`)"
  default     = ""
}

variable "public_key_path" {
  description = "Path to your SSH public key (e.g. `~/.ssh/id_rsa.pub`)"
  default     = "~/.ssh/id_rsa.pub"
}

variable "vpc_id" {
  description = "Use an existing VPC (please set create_vpc to false when using this)"
  default     = ""
}

variable "subnet_id" {
  description = "Use an existting Subnet in an existing VPC (please set create_vpc to false when using this)"
  default     = ""
}

variable "create_vpc" {
  description = "Create new VPC (e.g. `true` or `false`) - Please set to false when setting an existing vpc_id above - NOTE: no doublequotes around the true or false"
  default     = true
}

variable "use_ipv6" {
  description = "Use IPv4 AND IPv6 (e.g. `true` or `false`) - NOTE: no doublequotes around the true or false"
  default     = true
}

variable "use_ipv4only" {
  description = "Use IPv4 only (e.g. `true` or `false`) - Please set use_ipv6 to false when enabling this - NOTE: no doublequotes around the true or false"
  default     = false
}

variable "ec2_instance_type" {
  description = "EC2 instance type (e.g. `t2.medium` or `t2.small`)"
  default     = "t2.medium"
}

variable "packer_ami" {
  description = "Packer AMI ID to use for EC2 instance (NOTE: run `packer buidl packer.json` and use the generated AMI ID here)"
  default = "ami-10e00b6d"
}