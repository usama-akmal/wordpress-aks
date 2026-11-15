data "azurerm_virtual_network" "aks_lab" {
  name                = "aks-vnet-39405754"
  resource_group_name = "MC_rg-k8s-lab_aks-_eastus2"
}

resource "azurerm_virtual_network_peering" "project_to_aks" {
  name                      = "project-to-aks-lab"
  resource_group_name       = data.azurerm_resource_group.project.name
  virtual_network_name      = azurerm_virtual_network.project.name
  remote_virtual_network_id = data.azurerm_virtual_network.aks_lab.id
}

resource "azurerm_virtual_network_peering" "aks_to_project" {
  name                      = "aks-lab-to-project"
  resource_group_name       = data.azurerm_virtual_network.aks_lab.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.aks_lab.name
  remote_virtual_network_id = azurerm_virtual_network.project.id

  depends_on = [azurerm_virtual_network_peering.project_to_aks]
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql_aks_lab" {
  name                 = "mysql-to-aks-lab"
  private_dns_zone_id  = azurerm_private_dns_zone.mysql.id
  virtual_network_id   = data.azurerm_virtual_network.aks_lab.id
  registration_enabled = false
}
