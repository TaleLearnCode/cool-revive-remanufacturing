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
# Key Vault Secret
# #############################################################################

resource "azurerm_key_vault_secret" "secret" {
  name         = var.secret_name
  value        = var.secret_value
  key_vault_id = var.key_vault_id
}

# #############################################################################
# App Config Key/Value Pair
# #############################################################################

resource "azurerm_app_configuration_key" "app_config" {
  configuration_store_id = var.configuration_store_id
  key                    = var.app_config_key
  type                   = "vault"
  label                  = var.app_config_label
  vault_key_reference    = azurerm_key_vault_secret.secret.versionless_id
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}