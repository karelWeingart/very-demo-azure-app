resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = local.resource_name
  tags     = var.tags
}

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
  scope                = var.acr_registry.id
  role_definition_name = "acrPull"
  principal_id         = azurerm_user_assigned_identity.cont_app_user_identity.principal_id  
}

resource "azurerm_key_vault_access_policy" "app" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_user_assigned_identity.cont_app_user_identity.tenant_id
  object_id    = azurerm_container_app.app.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
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
    server   = var.acr_registry.login_server
  }

  template {
    container {
      name   = var.src_root_dir_name
      image  = "${var.acr_registry.login_server}/apps/${var.src_root_dir_name}:latest"
      cpu    = 0.25
      memory = "0.5Gi"
      dynamic "env" {    
      for_each = var.envs    
        content {      
          name = env.value["name"]      
          value = env.value["value"]    
        }   
      }
    }
    max_replicas = 1
    min_replicas = 1
    
  }
  ingress {
     allow_insecure_connections = false
     target_port = 8443
     transport = "http"     
     traffic_weight {
      percentage = 100
      latest_revision = true
     }
     external_enabled = true
   }   
}
