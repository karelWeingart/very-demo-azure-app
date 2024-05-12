data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "group" {
    name = "${var.environment}-functions"
    location = var.location
    tags     = var.tags
}
resource "random_string" "account" {
  length = 5
  min_lower = 5
  special = false
}

resource "azurerm_storage_account" "functions_storage_account" {
  name = "${var.environment}storage${random_string.account.result}"
  resource_group_name = azurerm_resource_group.group.name
  location = var.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "service_plan" {
  name = var.function_name
  resource_group_name = azurerm_resource_group.group.name
  location            = azurerm_resource_group.group.location
  os_type             = "Linux"
  sku_name            = "Y1"

}

resource "azurerm_application_insights" "function" {
  name                = "${var.environment}-${var.function_name}"
  location            = azurerm_resource_group.group.location
  resource_group_name = azurerm_resource_group.group.name
  application_type    = "web"
}

resource "azurerm_linux_function_app" "function" {
  name                       = var.function_name
 
  app_settings = merge({FUNCTIONS_WORKER_RUNTIME = "python"}, local.app_settings)

  site_config {
    application_insights_connection_string  = azurerm_application_insights.function.connection_string
    application_insights_key                = azurerm_application_insights.function.instrumentation_key


    application_stack {
      python_version              = "3.11"
      
    }
  }

  resource_group_name = azurerm_resource_group.group.name
  location            = azurerm_resource_group.group.location

  storage_account_name       = azurerm_storage_account.functions_storage_account.name
  storage_account_access_key = azurerm_storage_account.functions_storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.service_plan.id

  daily_memory_time_quota    = 10
  identity {
    type = "SystemAssigned"

  }

  sticky_settings {
    app_setting_names       = [
      "APPINSIGHTS_INSTRUMENTATIONKEY",
      "APPLICATIONINSIGHTS_CONNECTION_STRING ",
      "APPINSIGHTS_PROFILERFEATURE_VERSION",
      "APPINSIGHTS_SNAPSHOTFEATURE_VERSION",
      "ApplicationInsightsAgent_EXTENSION_VERSION",
      "XDT_MicrosoftApplicationInsights_BaseExtensions",
      "DiagnosticServices_EXTENSION_VERSION",
      "InstrumentationEngine_EXTENSION_VERSION",
      "SnapshotDebugger_EXTENSION_VERSION",
      "XDT_MicrosoftApplicationInsights_Mode",
      "XDT_MicrosoftApplicationInsights_PreemptSdk",
      "APPLICATIONINSIGHTS_CONFIGURATION_CONTENT",
      "XDT_MicrosoftApplicationInsightsJava",
      "XDT_MicrosoftApplicationInsights_NodeJS",
    ]
  }

}

resource "azurerm_key_vault_secret" "secret" {
  for_each      = local.key_vault_secrets
  
  name         = each.key
  key_vault_id = var.key_vault_id
  value        = each.value.value
  
  tags         = var.tags
}

resource "azurerm_key_vault_access_policy" "access_policty" {
 key_vault_id = var.key_vault_id
  tenant_id    = azurerm_linux_function_app.function.identity.0.tenant_id
  object_id    = azurerm_linux_function_app.function.identity.0.principal_id

  key_permissions = [
    "Get", "List"
  ]

  secret_permissions = [
    "Get", "List"
  ]
}
