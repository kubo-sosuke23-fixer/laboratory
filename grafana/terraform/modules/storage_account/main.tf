resource "azurerm_storage_account" "this" {
  name                            = replace(join("", compact(["st", var.product_name, var.subsystem_name, var.env, var.location.code])), "/[^0-9a-z]/", "")
  location                        = var.location.name
  resource_group_name             = var.resource_group_name
  account_tier                    = "Standard"
  account_replication_type        = "RAGRS"
  account_kind                    = "StorageV2"
  allow_nested_items_to_be_public = true
  min_tls_version                 = "TLS1_2"

  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 7
    }
  }

  network_rules {
    default_action = "Allow"
  }
}

# 証明書を入れるコンテナ
resource "azurerm_storage_container" "this" {
  name                  = "cert"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

# MySQL接続用の証明書
resource "azurerm_storage_blob" "this" {
  name                   = "DigiCertGlobalRootCA.crt.pem"
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.this.name
  type                   = "Block"
  source                 = "./modules/storage_account/DigiCertGlobalRootCA.crt.pem"
  content_type           = "application/octet-stream"
}