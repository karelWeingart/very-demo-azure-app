variable "location" {
    type    = string
    description = "region where keyvault is created"
}

variable "function_name" {
    type = string
    description = "name of the function (and name of directory where code is located.)"
}

variable "environment" {
    type = string
    description = "environment"
}

variable "tags" {
    type    = map(string)
    description = "default tags passed to module."
}

variable "app_settings" {
    type = map(string)
    description = "Env variables created in function runtime."
    default = null
}

variable "key_vault_id" {
    type = string
    description = "key vault id for storing secrets."
}

variable "function_secrets" {
    type = list(object({
        name = string
        value = string
        env_var_name = string
    }))
    description = "key vault id for storing secrets."
}
