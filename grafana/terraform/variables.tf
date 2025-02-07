#================================================================
#  Provider Configuration
#================================================================
variable "provider_credentials_azure" {
  description = <<-EOT
    A map object defining the credentials required to configure different infrastructures in Microsoft Azure using the Azure Resource Manager APIs. Each key in the map represents a distinct infrastructure component (e.g., main, cmk), and each value is an object containing the following properties:

    - **subscription_id** (Required, string):  
      The Subscription ID to be used. This can also be sourced from the `ARM_SUBSCRIPTION_ID` environment variable.

    - **tenant_id** (Required, string):  
      The Tenant ID to be used. This can also be sourced from the `ARM_TENANT_ID` environment variable.

    - **client_id** (Required, string):  
      The Client ID to be used. This can also be sourced from the `ARM_CLIENT_ID` environment variable.

    - **client_secret** (Required, string):  
      The Client Secret to be used. This should be sourced securely from environment variables or secret management tools.
    
    **Example:**

    ```hcl
    provider_credentials_azure = {
      subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      client_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      client_secret   = "your_client_secret"
    }
    ```
  EOT
  type = object({
    subscription_id = string
    tenant_id       = string
    client_id       = string
    client_secret   = string
  })
}

#================================================================
#  General
#================================================================
variable "product_name" {
  description = "The name of the product. This must be 6 characters or less."
  type        = string
  validation {
    condition     = length(var.product_name) <= 6
    error_message = "The variable product_name must be 6 characters or less."
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

#================================================================
#  Private Network
#================================================================
variable "vnet_address_space" {
  description = "The address space that is used the virtual network."
  type        = string
}

variable "subnet_address_prefix" {
  description = "Adress prefixes for the Subnets."
  type = object({
    mysql         = string
    swift_connect = string
  })
}