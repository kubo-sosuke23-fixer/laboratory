#================================================================
#  General
#================================================================
variable "product_name" {
  description = "The name of product. This value must be 6 characters or less."
  type        = string
  validation {
    condition     = length(var.product_name) <= 6
    error_message = "This value must be 6 characters or less."
  }
}

variable "subsystem_name" {
  description = "The name of the subsystem. This must be 3 characters or less."
  type        = string
  default     = null
  validation {
    condition     = length(var.subsystem_name) <= 3
    error_message = "The variable subsystem_name must be 3 characters or less."
  }
}

variable "env" {
  description = "Environment Type. The valid values are dev(dv), test(ts), stg(st) and prod(pr)."
  type        = string
  validation {
    condition     = contains(["dev", "dv", "test", "ts", "stg", "st", "prod", "pr"], var.env)
    error_message = "The valid values are dev(dv), test(ts), stg(st) and prod(pr)."
  }
}

variable "location" {
  description = <<-EOT
    An object specifying the geographical location for resources in Azure. This configuration includes the following properties:

    - **name** (Required, string):
      The full name of the Azure region where resources will be deployed. Examples include `japaneast`, `japanwest`, `eastus`, etc. This determines the physical location of your deployed resources.

    - **code** (Required, string):
      The abbreviated code for the Azure region, serving as a shorthand identifier. Examples include `je` for `japaneast`, `jw` for `japanwest`, `eus` for `eastus`, etc. This code can be used for internal references or naming conventions within scripts and configurations.
  EOT
  type = object({
    name = string
    code = string
  })
}

variable "common_tags" {
  description = "A mapping of tag keys and values assigned to all created resources."
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
}

#================================================================
#  Linux Web App
#================================================================
variable "web_app_resource_name" {
  description = "The name which should be used for this Linux Web App."
  type        = string
}

variable "auth_azuread_vars" {
  description = "value"
  type = object({
    name            = optional(string, "Azure AD")
    scopes          = optional(string, "openid email profile")
    enabled         = optional(bool, true)
    allowed_domains = optional(string, "fixer.co.jp")
    auth_url        = string
    token_url       = string
    client_id       = string
    client_secret   = string
  })
}

variable "database_vars" {
  description = "value"
  type = object({
    host             = string
    name             = string
    user_name        = string
    password         = string
    type             = string
    ssl_mode         = string
    cert_path        = string
    server_cert_name = string
  })
}

variable "storage_vars" {
  description = "value"
  type = object({
    storage_account_name   = string
    storage_container_name = string
    primary_access_key     = string
  })
}

variable "website_server_root_url" {
  description = "value"
  type        = string
}

#================================================================
#  Virtual Network Swift Connection
#================================================================
variable "swift_connect_subnet_id" {
  description = "The ID of the subnet the app service will be associated to."
  type        = string
}
