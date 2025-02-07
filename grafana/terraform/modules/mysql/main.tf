#================================================================
#  Random Password
#================================================================
resource "random_password" "this" {
  length           = var.length
  special          = var.special
  override_special = var.override_special
}

#================================================================
#  MySQL Server
#================================================================
resource "azurerm_mysql_flexible_server" "this" {
  name                   = join("-", compact(["mysql", var.product_name, var.subsystem_name, var.env, var.location.code]))
  location               = var.location.name
  resource_group_name    = var.resource_group_name
  administrator_login    = var.mysql_server_admin_username
  administrator_password = random_password.this.result
  sku_name               = var.mysql_server_sku_name
  version                = var.mysql_server_version
  backup_retention_days  = var.mysql_server_backup_retention_days
  delegated_subnet_id    = var.delegated_subnet_id
  private_dns_zone_id    = var.private_dns_zone_id

  storage {
    auto_grow_enabled = true
    iops              = var.mysql_server_storage_iops
    size_gb           = var.mysql_server_storage_size_gb
  }

  lifecycle {
    ignore_changes = [
      zone
    ]
  }

  # タイムアウトを設定
  timeouts {
    create = "30m"
  }
}

resource "azurerm_mysql_flexible_server_firewall_rule" "this" {
  name                = "azure"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.this.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"

  depends_on = [azurerm_mysql_flexible_server.this]
}

#================================================================
#  MySQL Database
#================================================================
resource "azurerm_mysql_flexible_database" "this" {
  name                = var.mysql_database_name
  server_name         = azurerm_mysql_flexible_server.this.name
  resource_group_name = var.resource_group_name
  charset             = var.mysql_database_charset
  collation           = var.mysql_database_collation

  depends_on = [azurerm_mysql_flexible_server.this]
}