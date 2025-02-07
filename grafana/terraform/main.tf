#################################################################
#  Grafana
#################################################################

#================================================================
#  Provider Configuration
#================================================================
# Main Subscription
provider "azurerm" {
  subscription_id = var.provider_credentials_azure.subscription_id
  tenant_id       = var.provider_credentials_azure.tenant_id
  client_id       = var.provider_credentials_azure.client_id
  client_secret   = var.provider_credentials_azure.client_secret
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azuread" {
  tenant_id     = var.provider_credentials_azure.tenant_id
  client_id     = var.provider_credentials_azure.client_id
  client_secret = var.provider_credentials_azure.client_secret
}

#================================================================
#  Data Blocks
#================================================================
data "azurerm_client_config" "current" {
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

  # Subsystem Nameをgrfに固定
  subsystem_name = "grf"

  # Service PrincipalとWeb Appの作成順序の影響で先にWeb Appの名前を指定
  web_app_resource_name = join("-", compact(["app", var.product_name, local.subsystem_name, local.env, var.location.code]))
}

#================================================================
#  Resource Group
#================================================================
resource "azurerm_resource_group" "this" {
  name     = join("-", compact(["rg", var.product_name, local.subsystem_name, local.env, var.location.code]))
  location = var.location.name
  tags     = var.common_tags

  lifecycle {
    ignore_changes = [tags]
  }
}

#================================================================
#  Private Network
#================================================================
module "private_network" {
  source = "github.com/fixer-github/FIXER.FSD.TerraformModules.git//private_network/templates/single_vnet"

  # General
  product_name   = var.product_name
  subsystem_name = local.subsystem_name
  env            = local.env
  location       = var.location
  common_tags    = var.common_tags

  # Resource Group
  create_resource_group        = false
  existing_resource_group_name = azurerm_resource_group.this.name

  # Virtual Network
  vnet_address_space = var.vnet_address_space

  # Private DNS Zone
  create_private_dns_zones = true
  private_dns_zones_list   = ["privatelink.mysql.database.azure.com"]

  # Subnet
  subnets = {
    mysql = {
      address_prefix     = var.subnet_address_prefix.mysql
      delegation_service = "Microsoft.DBforMySQL/flexibleServers"
    }
    swift_connect = {
      address_prefix     = var.subnet_address_prefix.swift_connect
      delegation_service = "Microsoft.Web/serverFarms"
    }
  }

  depends_on = [azurerm_resource_group.this]
}

#================================================================
#  Key Vault
#================================================================
resource "azurerm_key_vault" "this" {
  name                = join("-", compact(["kv", var.product_name, local.subsystem_name, local.env, var.location.code]))
  location            = var.location.name
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = var.common_tags

  enable_rbac_authorization     = true
  public_network_access_enabled = true

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_role_assignment" "this" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Secrets Officer"
  scope                = azurerm_key_vault.this.id
}

#================================================================
#  Service Principal
#================================================================
module "service_principal" {
  source = "./modules/service_principal"

  # General
  product_name   = var.product_name
  subsystem_name = local.subsystem_name
  env            = local.env

  # AzureAD Application
  redirect_uris = ["https://${local.web_app_resource_name}.azurewebsites.net/login/azuread"]
}

#================================================================
#  Storage Account for storing certificates for MySQL access
#================================================================
module "storage_account" {
  source = "./modules/storage_account"

  # General
  product_name        = var.product_name
  subsystem_name      = local.subsystem_name
  env                 = local.env
  location            = var.location
  common_tags         = var.common_tags
  resource_group_name = azurerm_resource_group.this.name
}

#================================================================
#  MySQL Server/Database
#================================================================
module "mysql" {
  source = "./modules/mysql"

  # General
  product_name        = var.product_name
  subsystem_name      = local.subsystem_name
  env                 = local.env
  location            = var.location
  common_tags         = var.common_tags
  resource_group_name = azurerm_resource_group.this.name

  # MySQL Server
  delegated_subnet_id = module.private_network.generic_subnet_id_map["mysql"]
  private_dns_zone_id = module.private_network.private_dns_zone_name_id_map["privatelink.mysql.database.azure.com"]

  depends_on = [module.private_network]
}

#================================================================
#  Web App
#================================================================
module "web_app" {
  source = "./modules/web_app"

  # General
  product_name        = var.product_name
  subsystem_name      = local.subsystem_name
  env                 = local.env
  location            = var.location
  common_tags         = var.common_tags
  resource_group_name = azurerm_resource_group.this.name

  # Linux Web App
  web_app_resource_name = local.web_app_resource_name
  auth_azuread_vars = {
    auth_url      = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/oauth2/v2.0/authorize"
    token_url     = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/oauth2/v2.0/token"
    client_id     = module.service_principal.client_id
    client_secret = module.service_principal.client_secret
  }
  database_vars = {
    host             = module.mysql.server_fqdn
    name             = module.mysql.database_name
    user_name        = module.mysql.administrator_login
    password         = module.mysql.administrator_password
    type             = "mysql"
    ssl_mode         = "true"
    cert_path        = "/etc/ssl/certs_ext/DigiCertGlobalRootCA.crt.pem"
    server_cert_name = module.mysql.server_fqdn
  }
  storage_vars = {
    storage_account_name   = module.storage_account.storage_account_name
    storage_container_name = module.storage_account.storage_container_name
    primary_access_key     = module.storage_account.primary_access_key
  }
  website_server_root_url = "${local.web_app_resource_name}.azurewebsites.net"

  # Virtual Network Swift Connection
  swift_connect_subnet_id = module.private_network.generic_subnet_id_map["swift_connect"]
}
