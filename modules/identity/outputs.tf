output "group_ids" {
  description = "Map of group name to OpenNebula group ID"
  value = {
    for name, g in opennebula_group.group :
    name => g.id
  }
}
