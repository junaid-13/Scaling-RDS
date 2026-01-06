output "vpc" {
  description = "The VPC id of my vpc used for this infrastructure."
  value = module.vpc.vpc_id
}