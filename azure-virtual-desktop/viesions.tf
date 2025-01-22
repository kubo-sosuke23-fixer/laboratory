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
    azapi = {
      # Reference | https://registry.terraform.io/providers/Azure/azapi/latest/docs
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    acme = {
      # Reference | https://registry.terraform.io/providers/vancluever/acme/latest/docs
      source  = "vancluever/acme"
      version = "~> 2.28"
    }
    random = {
      # Reference | https://registry.terraform.io/providers/hashicorp/random/latest/docs
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
