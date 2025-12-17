module "opennebula_resources" {
  source = "./modules/resources"

  groups    = var.groups
  users     = var.users
  acls      = var.acls
  networks  = var.networks
  images    = var.images
  templates = var.templates
  vms       = var.vms
  hosts     = var.hosts  
  group_ids = module.opennebula_resources.group_ids
}

resource "opennebula_group" "oneadmin_group" {
  name = "oneadmin"

  tags = {
    GROUP_DN = "cn=admins,cn=groups,cn=accounts,dc=nikou,dc=infra"
  }
}
