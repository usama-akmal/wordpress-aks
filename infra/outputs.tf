output "resource_group_name" {
  description = "Existing project resource group."
  value       = data.azurerm_resource_group.project.name
}

output "location" {
  description = "Azure region of the project resource group."
  value       = data.azurerm_resource_group.project.location
}

output "key_vault_name" {
  description = "Key Vault used for project secrets."
  value       = azurerm_key_vault.project.name
}
