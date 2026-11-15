resource "azurerm_container_registry" "project" {
  name                          = "acrwp${substr(sha1(lower(data.azurerm_resource_group.project.id)), 0, 12)}"
  resource_group_name           = data.azurerm_resource_group.project.name
  location                      = var.location
  sku                           = "Basic"
  admin_enabled                 = false
  public_network_access_enabled = true
}

output "acr_login_server" {
  description = "Registry hostname used by GitHub Actions and AKS."
  value       = azurerm_container_registry.project.login_server
}
