#================================================================
#  AzureAD Application
#================================================================
output "client_id" {
  description = "The client id of the azure ad application."
  value       = azuread_application.this.client_id
}

output "client_secret" {
  description = "The client secret of the azure ad application."
  value       = azuread_application_password.this.value
  sensitive   = true
}
