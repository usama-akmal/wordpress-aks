resource "azurerm_private_dns_zone" "mysql" {
  name                = "finalproject.private.mysql.database.azure.com"
  resource_group_name = data.azurerm_resource_group.project.name

  tags = {
    project = "wordpress-aks"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                 = "link-mysql-project-vnet"
  private_dns_zone_id  = azurerm_private_dns_zone.mysql.id
  virtual_network_id   = azurerm_virtual_network.project.id
  registration_enabled = false
}
