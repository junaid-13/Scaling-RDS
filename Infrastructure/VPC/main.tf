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
  source                        = "terraform-aws-modules/vpc/aws"
  name                          = "${var.name}-vpc"
  cidr                          = var.cidr
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false
}

#############################
######## Subnets ############
#############################

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

#############################
###### Internet Gateway #####
#############################

resource "aws_internet_gateway" "aws_igw" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_internet_gateway_attachment" "aws_igw_attach" {
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = aws_internet_gateway.aws_igw.id
}

#############################
###### Route Tables #########
#############################

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

resource "aws_route_table_association" "public_rt_assoc" {
    for_each = aws_subnet.pub_sub
    subnet_id = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
    vpc_id = module.vpc.vpc_id
    route {
        cidr_block = var.cidr
    }
    tags = "${var.name}-private-rt"
  
}

resource "aws_route_table_association" "private_rt_assoc" {
  for_each = aws_subnet.pri_sub
  subnet_id = each.value.id
  route_table_id = aws_route_table.private_rt.id
}

#############################
########## NACL #############
#############################

resource "aws_network_acl" "aws_pub_sub_acl" {
  vpc_id = module.vpc.vpc_id

  ingress {
    action     = "allow"
    rule_no    = 100
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"
    cidr_block = var.cidr
  }


  tags = {
    Name = "${var.name}-NACL"
  }
}

resource "aws_network_acl_association" "aws_pub_sub_acl_association" {
  network_acl_id = aws_network_acl.aws_pub_sub_acl.id
  for_each       = aws_subnet.pub_sub
  subnet_id      = each.value.id
}