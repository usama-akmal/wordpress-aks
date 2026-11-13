data "azurerm_client_config" "current" {}

locals {
  key_vault_name = "kv-wp-${substr(sha1(data.azurerm_resource_group.project.id), 0, 12)}"
}

resource "azurerm_key_vault" "project" {
  name                = local.key_vault_name
  location            = data.azurerm_resource_group.project.location
  resource_group_name = data.azurerm_resource_group.project.name

  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name  = "standard"

  rbac_authorization_enabled = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  public_network_access_enabled = true

  tags = {
    project = "wordpress-aks"
  }
}

resource "azurerm_role_assignment" "key_vault_operator" {
  scope                = azurerm_key_vault.project.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
