variable "environment" {
    type    = string
    description = "environment for which the key vault is created."
    default = ""
}

variable "tags" {
    type    = map(string)
    description = "default tags passed to module."
}

variable "name" {
    type    = string
    description = "Name of key vault. If environment var is filled then resulting name of vault is <var.environment>-<var.name>"
}

variable "location" {
    type    = string
    description = "region where keyvault is created"
}

variable "resource_group_name" {
    type    = string
    description = "Name of existing resource group. If specified then the keyvault'll be created there otherwise new resource group will be created."
    default  = ""
}

variable "key_vault_secrets" {
    type    = list(object({
      name = string
      value = string
    })
)

    description = "list of key vault secrets. Defaults to empty list."
    default = []
}

variable "ip_rules" {
    type = list(string)
    description = "List of ips/CIDR blocks which are allowed to access the key vault."
    default = []
}