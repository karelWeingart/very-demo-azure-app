locals {
    tags = {
        "env": var.environment
    }

    src_root_dir_name = "demo"

    resource_name = "${var.environment}-${local.src_root_dir_name}-app"
    subscription_id_alphanumeric = replace(reverse(split("/", data.azurerm_subscription.current.id))[0], "-", "")
}

data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = local.resource_name
  tags     = local.tags
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
  name = "CommonVault"
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

module "open_weather_crawler_function" {
  source = "../modules/functions"

  app_settings = {}

  key_vault_id = module.key_vault.key_vault.id

  function_secrets = [
    {
      name = "dbUser"
      value = "TO_BE_ADDED"
      env_var_name = "KEY_VAULT_DBUSER"
    },
    {
      name = "dbPswd"
      value = "TO_BE_ADDED"
      env_var_name = "KEY_VAULT_DBPSWD"
    },
    {
      name = "apiToken"
      value = "TO_BE_ADDED"
      env_var_name = "KEY_VAULT_OPENWEATHER_TOKEN"
    }
  ]

  function_name = "OpenWeatherCrawler"
  location = var.resource_group_location
  environment = var.environment
  tags = local.tags

}

module "db" {
  source = "../modules/azure_sql"
  
  environment = var.environment
  name = "demo-db"
  tags = local.tags
  location = var.resource_group_location

  admin_login_password = lookup(module.key_vault.key_vault_secrets, "dbAdminPasswd", "")
  admin_login_user = lookup(module.key_vault.key_vault_secrets, "dbAdminUser", "")
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.environment}${local.subscription_id_alphanumeric}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
  public_network_access_enabled = true
  tags                = local.tags
}

## Container app
resource "azurerm_log_analytics_workspace" "analytics_workspace" {
  name                = local.resource_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "app_environment" {
  name                       = local.resource_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.analytics_workspace.id
}

resource "azurerm_user_assigned_identity" "cont_app_user_identity" {
  location            = azurerm_resource_group.rg.location
  name                = local.resource_name
  resource_group_name = azurerm_resource_group.rg.name  
}

resource "azurerm_role_assignment" "acrpull_mi" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "acrPull"
  principal_id         = azurerm_user_assigned_identity.cont_app_user_identity.principal_id  
}


resource "azurerm_container_app" "app" {
  name                         = local.resource_name
  container_app_environment_id = azurerm_container_app_environment.app_environment.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"
  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.cont_app_user_identity.id ]
  }
  
  registry {
    identity = azurerm_user_assigned_identity.cont_app_user_identity.id
    server   = azurerm_container_registry.acr.login_server
  }
  
  template {
    container {
      name   = "verydemoazureapp"
      image  = "${azurerm_container_registry.acr.login_server}/demoweb/verydemoazureapp:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
  ingress {
     allow_insecure_connections = true
     target_port = 8443
     transport = "http"     
     traffic_weight {
      percentage = 100
      latest_revision = true
     }
     external_enabled = true
   }
}

