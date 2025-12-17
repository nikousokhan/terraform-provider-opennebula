output "group_ids" {
  value = { for group in opennebula_group.group : group.name => group.id }
}

output "network_ids" {
  value = { for net in opennebula_virtual_network.virtual_networks : net.name => net.id }
}

output "image_ids" {
  value = { for img in opennebula_image.image : img.name => img.id }
}