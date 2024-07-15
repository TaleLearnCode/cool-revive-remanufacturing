# #############################################################################
# Required Providers
# #############################################################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

# #############################################################################
# Referenced Resources
# #############################################################################

data "azurerm_resource_group" "function_app_rg" {
  name = var.resource_group_name
}

# #############################################################################
# Storage Account
# #############################################################################

resource "azurerm_storage_account" "function_storage" {
  name                     = lower("${module.storage_account.name.abbreviation}${var.storage_account_name}${var.resource_name_suffix}${var.azure_environment}${module.azure_regions.region.region_short}")
  resource_group_name      = data.azurerm_resource_group.function_app_rg.name
  location                 = data.azurerm_resource_group.function_app_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# #############################################################################
# App Service Plan (server farm)
# #############################################################################

resource "azurerm_service_plan" "app_service_plan" {
  name                = "${module.app_service_plan.name.abbreviation}-${var.function_app_name}${var.resource_name_suffix}-${var.azure_environment}-${module.azure_regions.region.region_short}"
  resource_group_name = data.azurerm_resource_group.function_app_rg.name
  location            = data.azurerm_resource_group.function_app_rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = var.tags
}

# #############################################################################
# Function App
# #############################################################################

resource "azurerm_linux_function_app" "function_app" {
  name                       = "${module.function_app.name.abbreviation}-${var.function_app_name}${var.resource_name_suffix}-${var.azure_environment}-${module.azure_regions.region.region_short}"
  resource_group_name        = data.azurerm_resource_group.function_app_rg.name
  location                   = data.azurerm_resource_group.function_app_rg.location
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.app_service_plan.id
  tags                       = var.tags
  

  site_config {
    ftps_state             = "FtpsOnly"
    application_stack {
      dotnet_version              = "8.0"
      use_dotnet_isolated_runtime = true
    }
    application_insights_connection_string = var.app_insights_connection_string
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = merge({
    "AzureWebJobsStorage__accountName" = azurerm_storage_account.function_storage.name,
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.app_insights_connection_string
  }, var.app_settings)
  lifecycle {
    ignore_changes = [storage_uses_managed_identity]
  }
}

# #############################################################################
# Role Assignments
# #############################################################################

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_function_app.function_app.identity.0.principal_id
}

resource "azurerm_role_assignment" "app_configuration_data_owner" {
  scope                = var.app_configuration_id
  role_definition_name = "App Configuration Data Owner"
  principal_id         = azurerm_linux_function_app.function_app.identity.0.principal_id
}