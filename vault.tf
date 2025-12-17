provider "vault" {
  address = var.VAULT_ADDRESS

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.ROLE_ID
      secret_id = var.SECRET_ID
    }
  }
}

data "vault_generic_secret" "sysops" {
  path = "kv/SysOps/secrets/opennebula/opennebula"
}
