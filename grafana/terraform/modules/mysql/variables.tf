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
#  Random Password
#================================================================
variable "length" {
  description = "文字列の長さ文字列の長さ"
  type        = number
  default     = 32
}

variable "special" {
  description = "特殊文字を含めるか"
  type        = bool
  default     = true
}

variable "override_special" {
  type    = string
  default = "!@^&()-+=[]|:"
}

#================================================================
#  MySQL Server
#================================================================
variable "mysql_server_admin_username" {
  description = "MySQL Server Administrator User Name (Default: grafanadbadmin)"
  type        = string
  default     = "grafanadbadmin"
}

variable "mysql_server_sku_name" {
  description = "The SKU Name for the MySQL Flexible Server."
  type        = string
  validation {
    condition     = can(regex("^(B|GP|MO)", var.mysql_server_sku_name))
    error_message = "The valid values must start with 'B', 'GP', or 'MO'."
  }
  default = "B_Standard_B1ms"
}

variable "mysql_server_version" {
  description = "The version of the MySQL Flexible Server to use."
  type        = string
  validation {
    condition     = contains(["5.7", "8.0.21"], var.mysql_server_version)
    error_message = "The valid values are 5.7 or 8.0.21."
  }
  default = "8.0.21"
}

variable "mysql_server_backup_retention_days" {
  description = "The backup retention days for the MySQL Flexible Server."
  type        = number
  validation {
    condition     = var.mysql_server_backup_retention_days >= 1 && var.mysql_server_backup_retention_days <= 35
    error_message = "The valid values must be a number between 1 and 35."
  }
  default = 7
}

variable "delegated_subnet_id" {
  description = "The ID of the subnet."
  type        = string
}

variable "private_dns_zone_id" {
  description = "The ID of the private dns zone for MySQL."
  type        = string
}

variable "mysql_server_storage_iops" {
  description = "The storage IOPS for the MySQL Flexible Server."
  type        = number
  validation {
    condition     = var.mysql_server_storage_iops >= 360 && var.mysql_server_storage_iops <= 20000
    error_message = "The valid values must be a number between 360 and 20000."
  }
  default = 360
}

variable "mysql_server_storage_size_gb" {
  description = "The max storage allowed for the MySQL Flexible Server."
  type        = number
  validation {
    condition     = var.mysql_server_storage_size_gb >= 20 && var.mysql_server_storage_size_gb <= 16384
    error_message = "The valid values must be a number between 20 and 16384."
  }
  default = 20
}

#================================================================
#  MySQL Database
#================================================================
variable "mysql_database_name" {
  description = "The name of the MySQL Database, which needs to be a valid MySQL identifier."
  type        = string
  default     = "grafana"
}

variable "mysql_database_charset" {
  description = "The Charset for the MySQL Database, which needs to be a valid MySQL Charset."
  type        = string
  default     = "utf8"
}

variable "mysql_database_collation" {
  description = "The Collation for the MySQL Database, which needs to be a valid MySQL Collation."
  type        = string
  default     = "utf8_unicode_ci"
}