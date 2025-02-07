#================================================================
#  MySQL Server
#================================================================
output "server_name" {
  description = "The name of the MySQL Flexible Server."
  value       = azurerm_mysql_flexible_server.this.name
}

output "server_id" {
  description = "The ID of the MySQL Flexible Server."
  value       = azurerm_mysql_flexible_server.this.id
}

output "server_fqdn" {
  description = "The fully qualified domain name of the MySQL Flexible Server."
  value       = azurerm_mysql_flexible_server.this.fqdn
}

output "administrator_login" {
  description = "The Administrator login of the MySQL Flexible Server."
  value       = azurerm_mysql_flexible_server.this.administrator_login
}

output "administrator_password" {
  description = "The Administrator password of the MySQL Flexible Server."
  value       = azurerm_mysql_flexible_server.this.administrator_password
  sensitive   = true
}

#================================================================
#  MySQL Database
#================================================================
output "database_name" {
  description = "The name of the MySQL Database."
  value       = azurerm_mysql_flexible_database.this.name
}
