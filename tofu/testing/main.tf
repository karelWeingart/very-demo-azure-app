locals {
    tags = {
        "env": var.environment
    }

}

resource "random_password" "db_admin_user" {
  length           = 10
  special          = false  
}

resource "random_password" "db_admin_pw" {
  length           = 32
  special          = true
}

module "key_vault" {
  source = "../modules/key_vault"
  
  environment = var.environment
  name = var.common_key_vault_name
  tags = local.tags
  location = var.resource_group_location
  key_vault_secrets = [
      {
        name = "dbAdminPasswd"
        value = random_password.db_admin_pw.result
      },
      {
        name = "dbAdminUser"
        value = random_password.db_admin_user.result
      }
    ]
}

module "acr" {
  source = "../modules/acr"

  resource_group_location = var.resource_group_location
  environment = var.environment
  tags = local.tags
  name = "${var.environment}"
}

# module "db" {
#   source = "../modules/azure_sql"
  
#   environment = var.environment
#   name = "demo-db"
#   tags = local.tags
#   location = var.resource_group_location
#   admin_login_password = lookup(module.key_vault.key_vault_secrets, "dbAdminPasswd", "")
#   admin_login_user = lookup(module.key_vault.key_vault_secrets, "dbAdminUser", "")
# }


module "container_apps" {
  source = "../modules/container_apps"

  acr_registry = module.acr.acr
  resource_group_location = var.resource_group_location
  tags = local.tags
  src_root_dir_name = "influxdb"
  environment = var.environment
  key_vault_id = module.key_vault.key_vault_id
  envs = [
    {name: "KEYVAULT_ENDPOINT",
    value: module.key_vault.key_vault_uri}
  ]
}
