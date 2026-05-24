variable "groups" {}
variable "users" {}
variable "acls" {}
variable "networks" {}
variable "images" {}
variable "hosts" {}
variable "templates" {}
variable "vms" {}
variable "default_group" {}

variable "one_endpoint" {
  type = string
}

variable "one_username" {
  type = string
}

variable "one_password" {
  type      = string
  sensitive = true
}
