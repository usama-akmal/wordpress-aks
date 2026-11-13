output "resource_group_name" {
  description = "Existing project resource group."
  value       = data.azurerm_resource_group.project.name
}

output "location" {
  description = "Azure region of the project resource group."
  value       = data.azurerm_resource_group.project.location
}
