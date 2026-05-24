module "environment" {
  source = "../../modules/environment"

  providers = {
    opennebula = opennebula
  }

  groups        = var.groups
  users         = var.users
  acls          = var.acls
  networks      = var.networks
  images        = var.images
  hosts         = var.hosts
  templates     = var.templates
  vms           = var.vms
  default_group = var.default_group
}
