variable "resource_group_location" {
    type        = string
    default     = "germanywestcentral"
    description = "Location of the resource group."
}

variable "environment" {
  type        = string
  default     = "test"
  description = "Environment name (used througout tagging etc)"
}

variable "common_key_vault_name" {
  type = string
  description = "Name of common key vault."
}
