output "client_ip" {
    value = data.http.ip.response_body
}

output "key_vault_secrets" {
    value = local.key_vault_secrets
}

output "key_vault" {
    value = azurerm_key_vault.vault
}