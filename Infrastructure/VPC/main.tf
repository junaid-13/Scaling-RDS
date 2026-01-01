data "aws_region" "current" {}

locals {
  pub_sub = ["10.0.1.0/24", "10.0.3.0/24", "10.0.5.0/24"]
  pri_sub = ["10.0.50.0/24", "10.0.51.0/24", "10.0.52.0/24"]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "${var.name}-vpc"
  cidr = var.cidr
}

resource "aws_subnet" "pub_sub" {
    for_each = local.pub_sub
    vpc_id = module.vpc.id
    availability_zone = var.azs[each.value]
    cidr_block = each.value
    tags = {
  name = for_each["${var.name}-public-subnet-${each.key}"]
}
}