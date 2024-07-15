# #############################################################################
# Core Remanufacturing resources
# #############################################################################

# -----------------------------------------------------------------------------
#                             Tags
# -----------------------------------------------------------------------------

variable "global_tag_product" {
  type        = string
  default     = "Remanufacturing"
  description = "The product or service that the resources are being created for."
}

variable "global_tag_cost_center" {
  type        = string
  default     = "Remanufacturing"
  description = "Accounting cost center associated with the resource."
}

variable "global_tag_criticality" {
  type        = string
  default     = "Medium"
  description = "The business impact of the resource or supported workload. Valid values are Low, Medium, High, Business Unit Critical, Mission Critical."
}

variable "global_tag_disaster_recovery" {
  type        = string
  default     = "Dev"
  description = "Business criticality of the application, workload, or service. Valid values are Mission Critical, Critical, Essential, Dev."
}

locals {
  global_tags = {
    Product     = var.global_tag_product
    Criticality = var.global_tag_criticality
    CostCenter  = "${var.global_tag_cost_center}-${var.azure_environment}"
    DR          = var.global_tag_disaster_recovery
    Env         = var.azure_environment
  }
}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "global" {
  name     = "${module.resource_group.name.abbreviation}-CoolRevive-${var.azure_environment}-${module.azure_regions.region.region_short}"
  location = module.azure_regions.region.region_cli
  tags     = local.global_tags
}

# -----------------------------------------------------------------------------
# API Management
# -----------------------------------------------------------------------------

variable "apim_publisher_name" {
  type        = string
  description = "The name of the publisher of the API Management instance."
}

variable "apim_publisher_email" {
  type        = string
  description = "The email address of the publisher of the API Management instance."
}

variable "apim_sku_name" {
  type        = string
  description = "The SKU of the API Management instance."
}

resource "azurerm_api_management" "global" {
  name                = lower("${module.api_management.name.abbreviation}-CoolRevive${var.resource_name_suffix}-${var.azure_environment}-${module.azure_regions.region.region_short}")
  location            = azurerm_resource_group.global.location
  resource_group_name = azurerm_resource_group.global.name
  publisher_name      = var.apim_publisher_name
  publisher_email     = var.apim_publisher_email
  sku_name            = var.apim_sku_name
  tags                = local.global_tags
}