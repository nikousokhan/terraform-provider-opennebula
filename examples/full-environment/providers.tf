terraform {
  required_providers {
    opennebula = {
      source  = "OpenNebula/opennebula"
      version = "~> 1.4"
    }
  }
}

provider "opennebula" {
  endpoint = "https://example.com:2633/RPC2"
}

