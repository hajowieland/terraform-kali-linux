## VPC:
resource "aws_vpc" "new-vpc" {
  count = "${var.create_vpc == 1 ? 1 : 0}"

  cidr_block                       = "${var.vpc_cidr}"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = "${var.use_ipv6 == 0 ? true : false}"

  tags = {
    Project   = "kali"
    ManagedBy = "terraform"
  }
}

data "aws_vpc" "vpc" {
  id = "${var.create_vpc == 0 ? var.vpc_id : "${join("", aws_vpc.new-vpc.*.id)}"}"
}

## Subnets

resource "aws_subnet" "public-subnet" {
  count                           = "${var.create_vpc == 1 ? 1 : 0}"
  vpc_id                          = "${data.aws_vpc.vpc.id}"
  cidr_block                      = "${var.subnet_cidr_block}"
  assign_ipv6_address_on_creation = "${var.use_ipv6 == true ? true : false}"

  tags = {
    Project   = "kali"
    ManagedBy = "terraform"
  }

  depends_on = ["aws_vpc.new-vpc"]
}

data "aws_subnet" "subnet" {
  id = "${var.subnet_id != "" ? var.subnet_id : "${join("", aws_subnet.public-subnet.*.id)}"}"
}

## Internet Gateway
resource "aws_internet_gateway" "igw" {
  count  = "${var.create_vpc == 1 ? 1 : 0}"
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags = {
    Project   = "kali"
    ManagedBy = "terraform"
  }
}

## Route Table

resource "aws_route_table" "rt-ipv6" {
  count  = "${var.create_vpc * var.use_ipv6 == 1 ? 1 : 0}"
  vpc_id = "${aws_vpc.new-vpc[count.index].id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw[count.index].id}"
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = "${aws_internet_gateway.igw[count.index].id}"
  }

  tags = {
    Project   = "kali"
    ManagedBy = "terraform"
  }
}

resource "aws_route_table" "rt-ipv4only" {
  count  = "${var.create_vpc * var.use_ipv4only == 1 ? 1 : 0}"
  vpc_id = "${aws_vpc.new-vpc[count.index].id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw[count.index].id}"
  }

  tags = {
    Project   = "kali"
    ManagedBy = "terraform"
  }
}

resource "aws_route_table_association" "rtassoc" {
  count = "${var.create_vpc == 1 ? 1 : 0}"

  subnet_id      = "${aws_subnet.public-subnet[count.index].id}"
  route_table_id = "${var.use_ipv6 == 1 ? "${join("", aws_route_table.rt-ipv6.*.id)}" : "${join("", aws_route_table.rt-ipv4only.*.id)}"}"
}

## Security Group

resource "aws_security_group" "sg-ipv6" {
  count       = "${var.use_ipv6 == 1 ? 1 : 0}"
  name        = "kali-ipv6"
  description = "Allow all IPv4 and IPv6 for kali"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Project   = "kali"
    ManagedBy = "terraform"
  }
}

resource "aws_security_group" "sg-ipv4-only" {
  count       = "${var.use_ipv4only == 1 ? 1 : 0}"
  name        = "kali-ipv4only"
  description = "Allow all IPv4 for kali"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project   = "kali"
    ManagedBy = "terraform"
  }
}

# data "aws_security_group" "sg" {
#   id = "${var.create_vpc * var.use_ipv6 == 0 ? aws_security_group.sg-ipv6.id : aws_security_group.sg-ipv4-only.id}"
# }

## SSH Key pair

resource "aws_key_pair" "ssh_key_pair" {
  count      = "${var.ssh_key_pair_name == "" ? 1 : 0}"
  key_name   = "kali-ssh-key"
  public_key = "${file("${var.public_key_path}")}"
}

locals {
  key_pair_name = "${var.ssh_key_pair_name == "" ? aws_key_pair.ssh_key_pair.0.key_name : var.ssh_key_pair_name}"
}

## EC2 instance

## TODO: check why the AMI doesnt use this userdata:
locals {
  kali-userdata = <<USERDATA
#!/bin/bash
apt-get update
apt-get dist-upgrade -y
USERDATA
}

resource "aws_instance" "kali_machine" {
  ami                         = "${var.packer_ami}"
  instance_type               = "${var.ec2_instance_type}"
  monitoring                  = false
  vpc_security_group_ids      = ["${var.use_ipv6 == 1 ? "${join("", aws_security_group.sg-ipv6.*.id)}" : "${join("", aws_security_group.sg-ipv4-only.*.id)}"}"]
  associate_public_ip_address = true
  subnet_id                   = "${data.aws_subnet.subnet.id}"
  key_name                    = "${local.key_pair_name}"
  source_dest_check           = false
  user_data_base64            = "${base64encode(local.kali-userdata)}"

  tags = {
    Project   = "kali"
    ManagedBy = "terraform"
  }
}
