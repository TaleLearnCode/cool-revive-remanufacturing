module "azure_regions" {
  source       = "git::https://github.com/TaleLearnCode/terraform-azure-regions.git"
  azure_region = var.azure_region
}

module "app_service_plan" {
  source = "git::https://github.com/TaleLearnCode/azure-resource-types.git"
  resource_type = "app-service-plan"
}

module "function_app" {
  source = "git::https://github.com/TaleLearnCode/azure-resource-types.git"
  resource_type = "function-app"
}

module "storage_account" {
  source        = "git::https://github.com/TaleLearnCode/azure-resource-types.git"
  resource_type = "storage-account"
}