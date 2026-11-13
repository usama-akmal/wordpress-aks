resource "azurerm_public_ip" "nat" {
  name                = "pip-final-project-nat"
  location            = data.azurerm_resource_group.project.location
  resource_group_name = data.azurerm_resource_group.project.name

  allocation_method = "Static"
  sku               = "Standard"

  tags = {
    project = "wordpress-aks"
  }
}

resource "azurerm_nat_gateway" "application" {
  name                = "nat-final-project"
  location            = data.azurerm_resource_group.project.location
  resource_group_name = data.azurerm_resource_group.project.name

  sku_name                = "Standard"
  idle_timeout_in_minutes = 4

  tags = {
    project = "wordpress-aks"
  }
}

resource "azurerm_nat_gateway_public_ip_association" "application" {
  nat_gateway_id       = azurerm_nat_gateway.application.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "application" {
  subnet_id      = azurerm_subnet.application.id
  nat_gateway_id = azurerm_nat_gateway.application.id
}
