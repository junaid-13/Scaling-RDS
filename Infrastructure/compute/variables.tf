variable "name" {
  type    = string
  default = "Purge_db"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}