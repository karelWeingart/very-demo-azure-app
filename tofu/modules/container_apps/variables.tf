variable "environment" {
    type = string
    description="env in which the resource is created"
}

variable "src_root_dir_name" {
    type = string
    description = "folder in this repo where app source is located"
}

variable "resource_group_location" {
    type        = string
    description = "Location of the resource group."
}

variable "tags" {
    type = map
    description = "tags for the resource"
}

variable "acr_registry" {
    description = "container registry object."
}

variable "key_vault_id" {
    type = string
    description = "keyvault for which app needs access"
}

variable "envs" {
    type = list(object(
            {
            name = string, 
            value = string
            }
    ))

    description="List of env vars with their values."
}