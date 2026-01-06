module "vpc" {
  source = "../VPC"
}

resource "aws_security_group" "bastion_sg" {
  vpc_id = module.vpc.vpc_id
  ingress = {
    type   = "tcp"
    port   = 22
    source = "0.0.0.0/0"
  }

  egress = {
    type        = "tcp"
    destination = "0.0.0.0/0"
  }
}

resource "aws_instance" "bastion_instance" {
  
}