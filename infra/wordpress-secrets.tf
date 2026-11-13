resource "azurerm_key_vault_secret" "wordpress_db_password" {
  name         = "wordpress-db-password"
  key_vault_id = azurerm_key_vault.project.id

  value_wo         = var.wordpress_db_password
  value_wo_version = 1

  depends_on = [
    azurerm_role_assignment.key_vault_operator
  ]
}

resource "azurerm_role_assignment" "wordpress_secret_reader" {
  scope = azurerm_key_vault_secret.wordpress_db_password.resource_versionless_id

  role_definition_name = "Key Vault Secrets User"

  principal_id = azurerm_linux_virtual_machine_scale_set.wordpress.identity[0].principal_id
}

