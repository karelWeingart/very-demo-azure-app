output "client_ip" {
    value = data.http.ip.response_body
}

output "key_vault_secrets" {
    value = local.key_vault_secrets
}

output "key_vault_id" {
    value = azurerm_key_vault.vault.id
}

output "key_vault_uri" {
    value = azurerm_key_vault.vault.vault_uri
}