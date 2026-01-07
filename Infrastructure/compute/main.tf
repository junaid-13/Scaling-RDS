module "vpc" {
  source = "../VPC"
}

#############################
########### AMI #############
#############################

data "aws_ami" "ubuntu_ami" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "image-id"
    values = ["ami-0b6c6ebed2801a5cb"]
  }
}


#############################
###### Security Group #######
#############################

resource "aws_security_group" "bastion_sg" {
  vpc_id = module.vpc.vpc
  name   = "Main-sg"
  tags = {
    name = "${var.name}-SG"
  }
  timeouts {
    create = "2m"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.bastion_sg.id
  ip_protocol       = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "default-egress" {
  security_group_id = aws_security_group.bastion_sg.id
  ip_protocol       = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 0
  to_port           = 0
}


#############################
######## Key Pair ###########
#############################

resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "tls_private_key" {
  content = tls_private_key.bastion_key.private_key_pem
  filename = pathexpand("${aws_key_pair.use_bastion_key.key_name}.pem")
  file_permission = "0600"
}

resource "aws_key_pair" "use_bastion_key" {
  key_name = "bastion-key"
  public_key = tls_private_key.bastion_key.public_key_openssh
}