module "vpc" {
  source = "./VPC"
}

module "compute" {
  source = "./compute"
}