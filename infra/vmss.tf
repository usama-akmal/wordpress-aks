resource "azurerm_linux_virtual_machine_scale_set" "wordpress" {
  name                = "vmss-wordpress"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.project.name

  sku                  = "Standard_B2als_v2"
  instances            = 1
  admin_username       = "azureuser"
  computer_name_prefix = "wpvm"

  disable_password_authentication = true
  overprovision                   = false
  upgrade_mode                    = "Manual"

  admin_ssh_key {
    username = "azureuser"

    public_key = trimspace(
      file(pathexpand(var.ssh_public_key_path))
    )
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nic-wordpress"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.application.id

      application_gateway_backend_address_pool_ids = [
        "${azurerm_application_gateway.wordpress.id}/backendAddressPools/wordpress-pool"
      ]
    }
  }

  identity {
    type = "SystemAssigned"
  }

  boot_diagnostics {}

  depends_on = [
    azurerm_subnet_network_security_group_association.application,
    azurerm_subnet_nat_gateway_association.application,
    azurerm_nat_gateway_public_ip_association.application
  ]

  tags = {
    project = "wordpress-aks"
  }
}
