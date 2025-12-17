resource "opennebula_group" "group" {
  for_each = var.groups
  name     = each.key
  tags = {
    GROUP_DN = each.value.group_dn
  }
  lifecycle {
    create_before_destroy = false
    ignore_changes = []
  }
}  

resource "opennebula_acl" "acls" {
  for_each = { for acl in var.acls : acl.user => acl }
  user     = contains(keys(var.group_ids), each.value.user) ? "@${var.group_ids[each.value.user]}" : each.value.user
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
  primary_group = lookup(var.group_ids, each.value.primary_group, 0)
  groups        = [for g in each.value.groups : lookup(var.group_ids, g, 0)]
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

resource "opennebula_virtual_network" "virtual_networks" {
  for_each        = var.networks
  name            = each.key
  bridge          = each.value.bridge
  type            = each.value.type
  security_groups = [0]
  cluster_ids     = [0]
  permissions     = "642"
  group           = "oneadmin"
  gateway         = each.value.gateway
  network_mask    = each.value.network_mask
  network_address = each.value.network_address
  mtu             = each.value.mtu
  tags = {
    VN_MAD      = each.value.VN_MAD
    BRIDGE_TYPE = "linux"
  }
lifecycle {
  ignore_changes = [mtu, guest_mtu]
}
}
resource "opennebula_virtual_network_address_range" "address_ranges" {
  for_each = { for idx, ar in flatten([for vn_key, vn in var.networks : [
    for ar_item in vn.ar : { network_key = vn_key, ar_item = ar_item }
  ]]) : "${ar.network_key}-${ar.ar_item.ip4}" => ar }

  virtual_network_id = opennebula_virtual_network.virtual_networks[each.value.network_key].id
  ar_type            = each.value.ar_item.ar_type
  size               = each.value.ar_item.size
  ip4                = each.value.ar_item.ip4
}

resource "opennebula_image" "image" {
  for_each = { for img in var.images : img.name => img }
  name         = each.value.name
  description  = "Terraform image"
  datastore_id = each.value.datastore_id
  persistent   = each.value.persistent
  lock         = each.value.lock
  path         = each.value.path
  dev_prefix   = each.value.dev_prefix
  driver       = each.value.driver
  permissions  = "660"
  group        = each.value.group
}

resource "opennebula_host" "host" {
  for_each = var.hosts
  name       = each.key
  type       = "kvm"
  cluster_id = each.value.cluster_id
  overcommit {
    cpu    = each.value.cpu
    memory = each.value.memory * 1048576
  }
  tags = {
    labels   = each.value.labels
  }
}

resource "opennebula_template" "template" {
  for_each = var.templates
  name        = each.key
  cpu         = 2
  vcpu        = 2
  memory      = 4 * 1024
  group       = "oneadmin"
  permissions = "660"
  hot_resize {
    cpu_hot_add_enabled    = "YES"  
    memory_hot_add_enabled = "YES"  
  }    
  memory_max = 50 * 1024
  vcpu_max = "24"
  memory_resize_mode = "Hotplug"    
  context = {
    NETWORK         = "YES"
    NETWORK_CONTEXT = "YES"
    VMNAME          = "$NAME"
    PASSWORD_BASE64 = "U25AcHBTZWNQYXNzMjAyMA=="
    USERNAME        = "snapp"
    TIMEZONE        = "Asia/Tehran"
    ROLEID          = "5c754d2c-870d-4a0a-62db-44555197264d"
    SECRETID        = "e486456d-a39b-d995-80e8-132ec4fdd06b"
    START_SCRIPT_base64    = each.value.start_script
  }
  graphics {
    type   = "VNC"
    listen = "0.0.0.0"
  }
  os {
    arch        = "x86_64"
    boot        = ""
  }
  disk {
    image_id = opennebula_image.image[each.value.image_id].id

    target   = "vda"
    driver   = "qcow2"
    cache    = "default"
    discard  = "ignore"
    io       = "threads"
  }
  dynamic "nic" {
    for_each = length(each.value.network_ids) > 0 ? each.value.network_ids : [null]
    content {
      model      = "virtio"
      network_id = nic.value != null ? opennebula_virtual_network.virtual_networks[nic.value].id : null
      
    }
  }
  cpumodel {
    model = "host-passthrough"
  }
  sched_requirements = each.value.sched_requirements
  depends_on = [
    opennebula_image.image
  ]
lifecycle {
  ignore_changes = [
    disk[0].driver
  ]
}
}

resource "opennebula_virtual_machine" "vm" {
  for_each = var.vms
  name        = each.key
  template_id = opennebula_template.template[each.value.template].id
  cpu         = each.value.cpu
  vcpu        = each.value.vcpu
  memory      = each.value.memory * 1024
  group       = each.value.group
  permissions = each.value.permissions
  context = {
    START_SCRIPT_base64 = (
      can(regex("^.*\\.db\\.(afra|asia)\\.snapp\\.infra$", each.key)) ? 
      "aWYgWyAhIC1mIC9ldGMvcmVzb2x2LmNvbmYgXTsgdGhlbgogICAgZWNobyAnbmFtZXNlcnZlciAxNzIuMjAuMS4yMicgPiAvZXRjL3Jlc29sdi5jb25mCmZpCgoKbWtkaXIgL2V0Yy9zc2gvYXV0aF9wcmluY2lwYWxzIC9yb290Ly5zc2gKcHJpbnRmICJzbmFwcCAgQUxMPShBTEwpIE5PUEFTU1dEOkFMTCIgPiAvZXRjL3N1ZG9lcnMuZC9zbmFwcApwcmludGYgJ3Jvb3QnID4gL2V0Yy9zc2gvYXV0aF9wcmluY2lwYWxzL3Jvb3QKcHJpbnRmICdyb290LHNuYXBwJyA+IC9ldGMvc3NoL2F1dGhfcHJpbmNpcGFscy9zbmFwcAp1c2VybW9kIC1zIC9iaW4vYmFzaCAkVVNFUk5BTUUKc3lzdGVtY3RsIHJlc3RhcnQgc3NoZAoKCmhvc3RuYW1lY3RsIHNldC1ob3N0bmFtZSAkVk1OQU1FCmV4cG9ydCBWTVNOQU1FPSR7Vk1OQU1FJSUuKn0Kc2VkICAtaSAnLzEyNy4wLjEuMS9kJyAvZXRjL2hvc3RzCnNlZCAtaWUgIi8xMjcuMC4wLjEgbG9jYWxob3N0L2EgMTI3LjAuMS4xICRWTU5BTUUgJFZNU05BTUUiIC9ldGMvaG9zdHMKCmNhdCA+IC9ldGMvcHJvZmlsZS5kL3NuYXBwX2NtZC5zaCA8PCBFT0YKIyEvYmluL3NoCmlmIFsgIlxgaWQgLXVcYCIgLWVxIDAgXTsgdGhlbgogICAgICAgIGV4cG9ydCBQUk9NUFRfQ09NTUFORD0nZXhwb3J0IFBTMT0iW1x1QFxIIFxXXSMgIicKICAgIGVsc2UKICAgICAgICBleHBvcnQgUFJPTVBUX0NPTU1BTkQ9J2V4cG9ydCBQUzE9IltcdUBcSCBcV10kICInCiAgICBmaQpFT0YKY2htb2QgK3ggL2V0Yy9wcm9maWxlLmQvc25hcHBfY21kLnNo" :  
      opennebula_template.template[each.value.template].context["START_SCRIPT_base64"]
    )
  }
  disk {
    image_id = opennebula_template.template[each.value.template].disk[0].image_id
    size     = each.value.disk_size * 1024
  }
  dynamic "disk" {
    for_each = lookup(each.value, "additional_disk", null) != null ? [1] : []
    content {
      size             = lookup(each.value.additional_disk, "size", 0) * 1024
      target           = lookup(each.value.additional_disk, "target", "vdb")
      driver           = null
      volatile_type    = lookup(each.value.additional_disk, "type", "fs")
      volatile_format  = lookup(each.value.additional_disk, "format", "qcow2")
    }
  } 
  dynamic "nic" {
    for_each = each.value.networks
    content {
      network_id = opennebula_virtual_network.virtual_networks[nic.value.network].id
      ip         = lookup(nic.value, "ip", null)
    }
  }
  tags = merge(
    each.value.tags != null ? each.value.tags : {},
    each.value.labels != null ? { labels = each.value.labels } : {}
  )
  sched_requirements = "ID=\"${lookup(opennebula_host.host, each.value.sched_requirements).id}\""  
  depends_on = [
    opennebula_virtual_network.virtual_networks,
    opennebula_host.host,
    opennebula_template.template
  ]
}