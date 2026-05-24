variable "groups" {
  description = "OpenNebula groups to be created"
  type = map(object({
    group_dn = string
  }))
}

variable "users" {
  description = "OpenNebula users"
  type = list(object({
    name          = string
    primary_group = string
    groups        = list(string)
  }))
}

variable "acls" {
  description = "OpenNebula ACL rules"
  type = list(object({
    user     = string
    resource = string
    rights   = string
  }))
}

