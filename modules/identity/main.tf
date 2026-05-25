resource "opennebula_group" "group" {
  for_each = var.groups
  name     = each.key
  tags = {
    GROUP_DN = each.value.group_dn
  }
  lifecycle {
    create_before_destroy = false
    ignore_changes        = []
  }
}

resource "opennebula_acl" "acls" {
  for_each = { for acl in var.acls : acl.user => acl }
  user     = contains(keys(opennebula_group.group), each.value.user) ? "@${opennebula_group.group[each.value.user].id}" : each.value.user
  resource = each.value.resource
  rights   = each.value.rights
  lifecycle {
    ignore_changes = [
      user,
      resource,
      rights
    ]
  }
  depends_on = [
    opennebula_group.group
  ]
}

resource "opennebula_user" "user" {
  for_each      = { for user in var.users : user.name => user }
  name          = each.value.name
  auth_driver   = "ldap"
  password      = "-"
  primary_group = opennebula_group.group[each.value.primary_group].id
  groups = [
    for g in each.value.groups :
    opennebula_group.group[g].id
  ]

  lifecycle {
    ignore_changes = [
      groups
    ]
  }

  depends_on = [
    opennebula_group.group,
    opennebula_acl.acls
  ]
}
