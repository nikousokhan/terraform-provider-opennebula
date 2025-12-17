terraform {
  required_providers {
    opennebula = {
      source = "nikou/opennebula"
      version = "1.4.0"
    }
    vault = {
      source  = "nikou/vault"
      version = "4.3.0"
    }
  }
  backend "http" {}
}

provider "opennebula" {
  endpoint = data.vault_generic_secret.sysops.data["opennebula_endpoint"]
  username = data.vault_generic_secret.sysops.data["user_opennebula"]
  password = data.vault_generic_secret.sysops.data["oneadmin_pass"]
}
