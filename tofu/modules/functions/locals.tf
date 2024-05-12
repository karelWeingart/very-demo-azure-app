locals {
    key_vault_secrets = {for secret in var.function_secrets: "function-${var.function_name}-${secret.name}" => 
            {value = secret.value, env_var_name = secret.env_var_name}
        }

    app_settings = merge(var.app_settings, {for secret_name, secret in local.key_vault_secrets: secret.env_var_name => secret_name})
}