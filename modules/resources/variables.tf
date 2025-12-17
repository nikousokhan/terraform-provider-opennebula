variable "groups" {
  description = "List of groups to create"
  type = map(object({
    group_dn = string
  }))
}

variable "group_ids" {
  description = "Mapping of group names to their IDs"
  type        = map(string)
}

variable "users" {
  type = list(object({
    name          = string
    primary_group = string
    groups        = list(string)
  }))
}

variable "acls" {
  description = "List of ACLs to create"
  type = map(object({
    user     = string
    resource = string
    rights   = string
  }))
}

variable "networks" {
  description = "List of virtual networks to create"
  type = map(object({
    name            = string
    bridge          = string
    type            = string
    gateway         = optional(string)
    network_mask    = string
    network_address = string
    mtu             = optional(string)
    ar              = list(object({
      ar_type = string
      size    = number
      ip4     = string
    }))
    VN_MAD = string
  }))
}

variable "images" {
  description = "List of images to create"
  type = list(object({
    name         = string
    datastore_id = number
    persistent   = bool
    lock         = string
    path         = string
    dev_prefix   = string
    driver       = string
    group        = string 
  }))
}  

variable "hosts" {
  description = "List of hosts to create"
  type = map(object({
    cluster_id   = string
    labels       = string
    cpu          = number
    memory       = number    
  }))
}

variable "templates" {
  description = "List of templates to create"
  type = map(object({
    image_id           = string
    network_ids        = list(string)
    sched_requirements = string
    start_script       = string 
  }))
}

variable "vms" {
  description = "List of VMs to create"
  type = map(object({
    template         = string
    cpu              = number
    vcpu             = number
    memory           = number
    disk_size        = number
    additional_disk  = optional(object({
      size     = number  
      target   = string
      type     = string
      format   = string
    }), null)    
    group            = string
    permissions      = number
    networks         = list(object({
      network = string
      ip      = optional(string)
    }))
    sched_requirements = string 
    labels             = string
    tags               = optional(map(string))
  }))
validation {
  condition = alltrue([
    for vm_key, vm in var.vms : alltrue([
      for nic in vm.networks : (
        nic.ip == "" ? true : (
          can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", nic.ip)) &&
          alltrue([
            for part in split(".", nic.ip) :
            can(tonumber(part)) && tonumber(part) >= 0 && tonumber(part) <= 255
          ])
        )
      )
    ])
  ])
  error_message = "One or more IP addresses in 'vms' are invalid. Use empty string or a valid IPv4 address (0.0.0.0 to 255.255.255.255)."
}
}
