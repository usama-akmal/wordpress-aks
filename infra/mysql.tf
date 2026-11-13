resource "azurerm_mysql_flexible_server" "project" {
  name = "mysql-wp-${substr(sha1(data.azurerm_resource_group.project.id), 0, 12)}"

  location            = var.location
  resource_group_name = data.azurerm_resource_group.project.name

  administrator_login               = "wpadmin"
  administrator_password_wo         = var.mysql_admin_password
  administrator_password_wo_version = 1

  version               = "8.4"
  sku_name              = "B_Standard_B1ms"
  backup_retention_days = 7

  delegated_subnet_id   = azurerm_subnet.database.id
  private_dns_zone_id   = azurerm_private_dns_zone.mysql.id
  public_network_access = "Disabled"

  storage {
    size_gb           = 32
    auto_grow_enabled = true
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.mysql,
    azurerm_key_vault_secret.mysql_admin_password
  ]

  tags = {
    project = "wordpress-aks"
  }
}

resource "azurerm_mysql_flexible_database" "wordpress" {
  name                = "wordpress"
  resource_group_name = data.azurerm_resource_group.project.name
  server_name         = azurerm_mysql_flexible_server.project.name

  charset   = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}
