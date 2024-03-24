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
