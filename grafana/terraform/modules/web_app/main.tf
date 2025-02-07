#================================================================
#  Web App Service Plan
#================================================================
resource "azurerm_service_plan" "this" {
  name                = join("-", compact(["asp", var.product_name, var.subsystem_name, var.env, var.location.code]))
  location            = var.location.name
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "P1v2"
}

#================================================================
#  Linux Web App
#================================================================
resource "azurerm_linux_web_app" "this" {
  #checkov:skip=CKV_AZURE_13:Grafanaに認証を設定するのでApp Service認証は不要
  #checkov:skip=CKV_AZURE_16:Grafanaの指定で認証するので、Managed IDは使用できない
  #checkov:skip=CKV_AZURE_17:Grafanaに認証を設定するのでクライアント証明書認証は不要
  #checkov:skip=CKV_AZURE_88:GrafanaはAzure Filesを使用しない

  name                    = var.web_app_resource_name
  location                = var.location.name
  resource_group_name     = var.resource_group_name
  service_plan_id         = azurerm_service_plan.this.id
  client_affinity_enabled = false
  https_only              = true

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = false
    "GF_AUTH_AZUREAD_NAME"                = var.auth_azuread_vars.name
    "GF_AUTH_AZUREAD_SCOPES"              = var.auth_azuread_vars.scopes
    "GF_AUTH_AZUREAD_ENABLED"             = var.auth_azuread_vars.enabled
    "GF_AUTH_AZUREAD_ALLOWED_DOMAINS"     = var.auth_azuread_vars.allowed_domains
    "GF_AUTH_AZUREAD_AUTH_URL"            = var.auth_azuread_vars.auth_url
    "GF_AUTH_AZUREAD_TOKEN_URL"           = var.auth_azuread_vars.token_url
    "GF_AUTH_AZUREAD_CLIENT_ID"           = var.auth_azuread_vars.client_id
    "GF_AUTH_AZUREAD_CLIENT_SECRET"       = var.auth_azuread_vars.client_secret
    "GF_DATABASE_HOST"                    = var.database_vars.host
    "GF_DATABASE_NAME"                    = var.database_vars.name
    "GF_DATABASE_USER"                    = var.database_vars.user_name
    "GF_DATABASE_PASSWORD"                = var.database_vars.password
    "GF_DATABASE_TYPE"                    = var.database_vars.type
    "GF_DATABASE_SSL_MODE"                = var.database_vars.ssl_mode
    "GF_DATABASE_CA_CERT_PATH"            = var.database_vars.cert_path
    "GF_DATABASE_SERVER_CERT_NAME"        = var.database_vars.server_cert_name
    "GF_SERVER_ROOT_URL"                  = "https://${var.website_server_root_url}/"
  }

  site_config {
    vnet_route_all_enabled            = true
    use_32_bit_worker                 = true
    always_on                         = true
    http2_enabled                     = true
    ftps_state                        = "FtpsOnly"
    app_command_line                  = "docker run -d -p 3000:3000"
    health_check_path                 = "/healthz"
    health_check_eviction_time_in_min = 10

    application_stack {
      docker_image_name   = "grafana/grafana:latest"
      docker_registry_url = "https://index.docker.io"
    }
  }

  storage_account {
    name         = "MySQLCert"
    type         = "AzureBlob"
    account_name = var.storage_vars.storage_account_name
    share_name   = var.storage_vars.storage_container_name
    access_key   = var.storage_vars.primary_access_key
    mount_path   = "/etc/ssl/certs_ext"
  }

  identity {
    type = "SystemAssigned"
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 25
      }
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_VNET_ROUTE_ALL"],
      virtual_network_subnet_id
    ]
  }
}

#================================================================
#  Virtual Network Swift Connection
#================================================================
resource "azurerm_app_service_virtual_network_swift_connection" "this" {
  app_service_id = azurerm_linux_web_app.this.id
  subnet_id      = var.swift_connect_subnet_id
}