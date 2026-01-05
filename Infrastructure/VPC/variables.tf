variable "name" {
  type    = string
  default = "Purge_db"
}

variable "cidr" {
  type    = string
  default = "125.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}