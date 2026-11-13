resource "azurerm_role_assignment" "db_bootstrap_reader" {
  count = var.enable_db_bootstrap ? 1 : 0

  scope = azurerm_key_vault_secret.mysql_admin_password.resource_versionless_id

  role_definition_name = "Key Vault Secrets User"

  principal_id = azurerm_linux_virtual_machine_scale_set.wordpress.identity[0].principal_id
}
