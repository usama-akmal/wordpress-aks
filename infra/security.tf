resource "azurerm_network_security_group" "application" {
  name                = "nsg-wordpress-vm"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.project.name

  security_rule {
    name                       = "Allow-HTTP-From-AppGateway"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = azurerm_subnet.gateway.address_prefixes[0]
    destination_address_prefix = azurerm_subnet.application.address_prefixes[0]
  }

  security_rule {
    name                       = "Deny-Other-Inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    project = "wordpress-aks"
  }
}

resource "azurerm_subnet_network_security_group_association" "application" {
  subnet_id                 = azurerm_subnet.application.id
  network_security_group_id = azurerm_network_security_group.application.id
}
