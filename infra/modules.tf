# #############################################################################
# Modules
# #############################################################################

module "azure_regions" {
  source       = "git::https://github.com/TaleLearnCode/terraform-azure-regions.git"
  azure_region = var.azure_region
}

module "resource_group" {
  source        = "git::https://github.com/TaleLearnCode/azure-resource-types.git"
  resource_type = "resource-group"
}

module "api_management" {
  source        = "git::https://github.com/TaleLearnCode/azure-resource-types.git"
  resource_type = "api-management-service-instance"
}

module "service_bus_namespace" {
  source        = "git::https://github.com/TaleLearnCode/azure-resource-types.git"
  resource_type = "service-bus-namespace"
}

module "cosmos_account" {
  source        = "git::https://github.com/TaleLearnCode/azure-resource-types.git"
  resource_type = "azure-cosmos-db-for-nosql-account"
}

module "log_analytics_workspace" {
  source = "git::https://github.com/TaleLearnCode/azure-resource-types.git"
  resource_type = "log-analytics-workspace"
}

module "application_insights" {
  source = "git::https://github.com/TaleLearnCode/azure-resource-types.git"
  resource_type = "application-insights"
}

module "key_vault" {
  source = "git::https://github.com/TaleLearnCode/azure-resource-types.git"
  resource_type = "key-vault"
}

module "app_config" {
  source = "git::https://github.com/TaleLearnCode/azure-resource-types.git"
  resource_type = "app-configuration-store"
}