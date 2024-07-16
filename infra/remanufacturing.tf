# #############################################################################
# Remanufacturing
# #############################################################################

# -----------------------------------------------------------------------------
#                             Tags
# -----------------------------------------------------------------------------

variable "remanufacturing_tag_product" {
  type        = string
  default     = "Remanufacturing"
  description = "The product or service that the resources are being created for."
}

variable "remanufacturing_tag_cost_center" {
  type        = string
  default     = "Remanufacturing"
  description = "Accounting cost center associated with the resource."
}

variable "remanufacturing_tag_criticality" {
  type        = string
  default     = "Medium"
  description = "The business impact of the resource or supported workload. Valid values are Low, Medium, High, Business Unit Critical, Mission Critical."
}

variable "remanufacturing_tag_disaster_recovery" {
  type        = string
  default     = "Dev"
  description = "Business criticality of the application, workload, or service. Valid values are Mission Critical, Critical, Essential, Dev."
}

locals {
  remanufacturing_tags = {
    Product     = var.remanufacturing_tag_product
    Criticality = var.remanufacturing_tag_criticality
    CostCenter  = "${var.global_tag_cost_center}-${var.azure_environment}"
    DR          = var.remanufacturing_tag_disaster_recovery
    Env         = var.azure_environment
  }
}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "remanufacturing" {
  name     = "${module.resource_group.name.abbreviation}-CoolRevive_Remanufacturing-${var.azure_environment}-${module.azure_regions.region.region_short}"
  location = module.azure_regions.region.region_cli
  tags     = local.global_tags
}

# -----------------------------------------------------------------------------
# Key Vault
# -----------------------------------------------------------------------------

resource "azurerm_key_vault" "remanufacturing" {
  name                        = lower("${module.key_vault.name.abbreviation}-Reman${var.resource_name_suffix}-${var.azure_environment}-${module.azure_regions.region.region_short}")
  location                    = azurerm_resource_group.remanufacturing.location
  resource_group_name         = azurerm_resource_group.remanufacturing.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  sku_name                    = "standard"
  enable_rbac_authorization  = true
  tags                        = local.remanufacturing_tags
}

resource "azurerm_role_assignment" "key_vault_administrator" {
  scope                = azurerm_key_vault.remanufacturing.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# -----------------------------------------------------------------------------
# App Configuration
# -----------------------------------------------------------------------------

resource "azurerm_app_configuration" "remanufacturing" {
  name                       = lower("${module.app_config.name.abbreviation}-Remanufacturing${var.resource_name_suffix}-${var.azure_environment}-${module.azure_regions.region.region_short}")
  resource_group_name        = azurerm_resource_group.remanufacturing.name
  location                   = azurerm_resource_group.remanufacturing.location
  sku                        = "standard"
  local_auth_enabled         = true
  public_network_access      = "Enabled"
  purge_protection_enabled   = false
  soft_delete_retention_days = 1
  tags                       = local.remanufacturing_tags
}

# Role Assignment: 'App Configuration Data Owner' to current Terraform user
resource "azurerm_role_assignment" "app_config_data_owner" {
  scope                = azurerm_app_configuration.remanufacturing.id
  role_definition_name = "App Configuration Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

# -----------------------------------------------------------------------------
# Log Analytics Workspace
# -----------------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "remanufacturing" {
  name                = lower("${module.log_analytics_workspace.name.abbreviation}-Remanufacturing${var.resource_name_suffix}-${var.azure_environment}-${module.azure_regions.region.region_short}")
  location            = azurerm_resource_group.remanufacturing.location
  resource_group_name = azurerm_resource_group.remanufacturing.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.remanufacturing_tags
}

# -----------------------------------------------------------------------------
# Application Insights
# -----------------------------------------------------------------------------

resource "azurerm_application_insights" "remanufacturing" {
  name                = lower("${module.application_insights.name.abbreviation}-Remanufacturing${var.resource_name_suffix}-${var.azure_environment}-${module.azure_regions.region.region_short}")
  location            = azurerm_resource_group.remanufacturing.location
  resource_group_name = azurerm_resource_group.remanufacturing.name
  workspace_id        = azurerm_log_analytics_workspace.remanufacturing.id
  application_type    = "web"
  tags                = local.remanufacturing_tags
}

# ------------------------------------------------------------------------------
# Production Schedule Facade
# ------------------------------------------------------------------------------

module "production_schedule_facade" {
  source = "./modules/function-consumption"
  app_configuration_id           = azurerm_app_configuration.remanufacturing.id
  app_insights_connection_string = azurerm_application_insights.remanufacturing.connection_string
  azure_environment              = var.azure_environment
  azure_region                   = var.azure_region
  function_app_name              = "ProductionScheduleFacade"
  key_vault_id                   = azurerm_key_vault.remanufacturing.id
  resource_group_name            = azurerm_resource_group.remanufacturing.name
  resource_name_suffix           = var.resource_name_suffix
  storage_account_name           = "psf"
  tags                           = local.remanufacturing_tags
  #app_settings = {
  #  "TableConnectionString"       = "@Microsoft.AppConfiguration(Endpoint=${azurerm_app_configuration.remanufacturing.endpoint}; Key=${module.global_storage_account_connection_string.key}; Label=${module.global_storage_account_connection_string.label})",
  #  "ProductionScheduleTableName" = "@Microsoft.AppConfiguration(Endpoint=${azurerm_app_configuration.remanufacturing.endpoint}; Key=${azurerm_app_configuration_key.production_schedule_table_name.key}; Label=${azurerm_app_configuration_key.production_schedule_table_name.label})",
  #}
  app_settings = {
    "TableConnectionString"       = azurerm_storage_account.global.primary_connection_string
    "ProductionScheduleTableName" = azurerm_storage_table.production_schedule.name
  }
  depends_on = [ azurerm_resource_group.remanufacturing ]
}