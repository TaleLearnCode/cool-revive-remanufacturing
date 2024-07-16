# #############################################################################
# Production Schedule
# #############################################################################

# ------------------------------------------------------------------------------
# Production Schedule "Legacy Application"
# ------------------------------------------------------------------------------

resource "azurerm_storage_table" "production_schedule" {
  name                 = "ProductionSchedule"
  storage_account_name = azurerm_storage_account.global.name
}

resource "azurerm_app_configuration_key" "production_schedule_table_name" {
  configuration_store_id = azurerm_app_configuration.remanufacturing.id
  key                    = "ProductionSchedule:Storage:TableName"
  label                  = var.azure_environment
  value                  = azurerm_storage_table.production_schedule.name
  lifecycle {
    ignore_changes = [configuration_store_id]
  }
}

locals {
  current_date = formatdate("YYYY-MM-DD", timestamp())
  core_ids = {
    0 = "ABC123"
    1 = "DEF456"
    2 = "GHI789"
    3 = "JKL987"
    4 = "MNO654"
    5 = "PQR321"
    6 = "STU159"
    7 = "VWX357"
    8 = "ZYA753"
    9 = "DCB951"
  }
}

resource "random_string" "finished_product_id" {
  length  = 10
  special = false
  upper   = true
}

resource "azurerm_storage_table_entity" "production_schedule_pod123" {
  count            = 10
  storage_table_id = azurerm_storage_table.production_schedule.id
  partition_key    = "pod123_${local.current_date}"
  row_key          = count.index + 1
  entity = {
    "PodId"    = "pod123",
    "Date"     = local.current_date,
    "Sequence" = count.index,
    "Model"    = "Model 3",
    "CoreId"   = local.core_ids[count.index],
    "FinishedProductId" = random_string.finished_product_id.result,
    "Status"   = "Scheduled",
  }
}