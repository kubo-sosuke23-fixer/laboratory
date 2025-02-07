#================================================================
#  Storage Account
#================================================================
output "storage_account_name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.this.name
}

output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.this.id
}

output "primary_access_key" {
  description = "The primary access key for the storage account."
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

#================================================================
#  Storage Container
#================================================================
output "storage_container_name" {
  description = "The name of the container containing the certificate."
  value       = azurerm_storage_container.this.name
}