resource "azurerm_virtual_network" "project" {
  name                = "vnet-final-project"
  location            = data.azurerm_resource_group.project.location
  resource_group_name = data.azurerm_resource_group.project.name
  address_space       = ["10.40.0.0/16"]

  tags = {
    project = "wordpress-aks"
  }
}

resource "azurerm_subnet" "application" {
  name                 = "snet-wordpress-vm"
  resource_group_name  = data.azurerm_resource_group.project.name
  virtual_network_name = azurerm_virtual_network.project.name
  address_prefixes     = ["10.40.1.0/24"]
}

resource "azurerm_subnet" "gateway" {
  name                 = "snet-app-gateway"
  resource_group_name  = data.azurerm_resource_group.project.name
  virtual_network_name = azurerm_virtual_network.project.name
  address_prefixes     = ["10.40.2.0/24"]
}

resource "azurerm_subnet" "database" {
  name                 = "snet-mysql"
  resource_group_name  = data.azurerm_resource_group.project.name
  virtual_network_name = azurerm_virtual_network.project.name
  address_prefixes     = ["10.40.3.0/27"]

  delegation {
    name = "mysql-delegation"

    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}
