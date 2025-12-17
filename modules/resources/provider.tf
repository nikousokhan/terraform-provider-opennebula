terraform {
  required_providers {
    opennebula = {
      source = "snapp/opennebula"
      version = "1.4.0"
    }
    vault = {
      source  = "snapp/vault"
      version = "4.3.0"
    }
  }
}