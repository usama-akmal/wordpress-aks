resource "azurerm_key_vault_secret" "mysql_admin_password" {
  name         = "mysql-admin-password"
  key_vault_id = azurerm_key_vault.project.id

  value_wo         = var.mysql_admin_password
  value_wo_version = 1

  depends_on = [
    azurerm_role_assignment.key_vault_operator
  ]
}
