data "aws_region" "current" {}

locals {
  pub_sub = {
    0 = "10.0.1.0/24"
    1 = "10.0.3.0/24"
    2 = "10.0.5.0/24"
  }
  pri_sub = {
    0 = "10.0.50.0/24"
    1 = "10.0.51.0/24"
    2 = "10.0.52.0/24"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "${var.name}-vpc"
  cidr   = var.cidr
}

resource "aws_subnet" "pub_sub" {
  for_each          = local.pub_sub
  vpc_id            = module.vpc.vpc_id
  availability_zone = var.azs[each.key]
  cidr_block        = each.value
  tags = {
    name = "${var.name}-public-subnet-${each.key}"
  }
}

resource "aws_subnet" "pri_sub" {
  for_each          = local.pri_sub
  vpc_id            = module.vpc.vpc_id
  availability_zone = var.azs[each.key]
  cidr_block        = each.value
  tags = {
    name = "${var.name}-private-subnet-${each.key}"
  }
}

resource "aws_internet_gateway" "aws_igw" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = module.vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_igw.id
  }

  tags = {
    name = "${var.name}-public-rt"
  }
}