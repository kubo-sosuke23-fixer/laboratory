#################################################################
#  Construction AVD
#################################################################

#================================================================
#  Provider Configuration
#================================================================
# Main Subscription
provider "azurerm" {
  subscription_id = var.provider_credentials_azure.main.subscription_id
  tenant_id       = var.provider_credentials_azure.main.tenant_id
  client_id       = var.provider_credentials_azure.main.client_id
  client_secret   = var.provider_credentials_azure.main.client_secret
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azuread" {
  tenant_id     = var.provider_credentials_azure.main.tenant_id
  client_id     = var.provider_credentials_azure.main.client_id
  client_secret = var.provider_credentials_azure.main.client_secret
}

provider "azapi" {
  subscription_id = var.provider_credentials_azure.main.subscription_id
  tenant_id       = var.provider_credentials_azure.main.tenant_id
  client_id       = var.provider_credentials_azure.main.client_id
  client_secret   = var.provider_credentials_azure.main.client_secret
}


#================================================================
#  Local Values
#================================================================
locals {
  # var.envを省略形(Abbreviation)に変換する際のマッピングを定義
  env_abbr = {
    dev  = "dv"
    test = "ts"
    stg  = "st"
    prod = "pr"
  }
  # envの省略形をlocal.envとして格納
  env = lookup(local.env_abbr, var.env, var.env)

  subsystem_name = "avd"
}

#================================================================
#  Resource Group
#================================================================
resource "azurerm_resource_group" "this" {
  name     = join("-", compact(["rg", var.product_name, local.subsystem_name, local.env, var.location.code]))
  location = var.location.name
}