variable "SECRET_ID" {
  type = string
}

variable "ROLE_ID" {
  type = string
}
variable "VAULT_ADDRESS" {
  type = string
  default = "https://vault.snapp.tech"
}

#####################################################################################
variable "groups" {
  description = "List of groups to create"
  type = map(object({
    group_dn = string
  }))
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
    ar = list(object({
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
    cluster_id = string
    labels     = string
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
    networks  = list(object({
      network = string
      ip      = optional(string)
    }))
    sched_requirements = optional(string)
    labels             = string
    tags               = optional(map(string))
  }))
}
