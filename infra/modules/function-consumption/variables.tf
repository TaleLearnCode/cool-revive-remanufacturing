variable "app_configuration_id" {
  type        = string
  default     = null
  description = "The ID of the App Configuration."
}

variable "app_insights_connection_string" {
  type        = string
  description = "The Application Insights connection string."
}

variable "app_settings" {
  description = "A map of additional app settings to configure for the Function App"
  type        = map(string)
  default     = {}
}

variable "azure_environment" {
	type        = string
	description = "The environment component of an Azure resource name."
}

variable "azure_region" {
	type        = string
	description = "Location of the resource group."
}

variable "function_app_name" {
  type        = string
  description = "The name of the Function App."
}

variable "key_vault_id" {
  type        = string
  default     = null
  description = "The ID of the Key Vault."
}

variable "resource_group_name" {
  type        = string
  description = "The base name of the resource group."
}

variable "resource_name_suffix" {
  type        = string
  description = "The suffix to append to the resource names."
}

variable "storage_account_name" {
  type        = string
  description = "The name of the Storage Account."
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources."
}