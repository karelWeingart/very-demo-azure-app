locals {
    vault_name = var.environment == "" ?  var.name : "${var.environment}${var.name}"

    ip_rules = concat(var.ip_rules, ["${data.http.ip.response_body}/32"])

    key_vault_secrets = {for secret in var.key_vault_secrets: secret.name => secret.value}
}