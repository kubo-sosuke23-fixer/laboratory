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

#================================================================
#  AzureAD Application
#================================================================
variable "redirect_uris" {
  description = ""
  type        = list(string)
}