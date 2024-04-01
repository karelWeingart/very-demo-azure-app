module "key_vault" {
  source = "../modules/key_vault"
  
  environment = var.environment
  name = "CommonVault"
  tags = local.tags
  location = var.resource_group_location
  key_vault_secrets = [
      {
        name = "dbAdminPasswd"
        value = random_password.db-admin-pw.result
      }
    ]
}