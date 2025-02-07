terraform {
  required_version = "~> 1.9"
  required_providers {
    azurerm = {
      # Reference | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
      source  = "hashicorp/azurerm"
      version = "~> 4.10"
    }
    azuread = {
      # Reference | https://registry.terraform.io/providers/hashicorp/azuread/latest/docs
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}
