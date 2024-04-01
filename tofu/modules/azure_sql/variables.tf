variable "admin_login_user" {
    type = string
    description = "administrator username."
}

variable "admin_login_password" {
    type = string
    description = "administrator password."
}

variable "name" {
    type = string
    description = "database name"
}

variable "environment" {
    type = string
    description = "environment"
}

variable "location" {
    type = string
    description = "region."
}

variable "tags" {
    type = map(string)
    description = "default tags."
}