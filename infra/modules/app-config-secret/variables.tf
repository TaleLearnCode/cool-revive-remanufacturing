variable "app_config_label" {
  type        = string
  description = "The label to apply to the App Configuration"
}

variable "app_config_key" {
  type        = string
  description = "The key to create in the App Configuration store"
}

variable "configuration_store_id" {
  type        = string
  description = "The ID of the App Configuration store to create the key in"
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault to create the secret in"
}

variable "secret_name" {
  type        = string
  description = "The name of the secret to create in the Key Vault"
}

variable "secret_value" {
  type        = string
  description = "The value of the secret to create in the Key Vault"
}