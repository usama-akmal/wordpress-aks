output "resource_group_name" {
  description = "Existing project resource group."
  value       = data.azurerm_resource_group.project.name
}

output "location" {
  description = "Azure region for the project workload."
  value       = var.location
}

output "key_vault_name" {
  description = "Key Vault used for project secrets."
  value       = azurerm_key_vault.project.name
}

output "mysql_server_name" {
  value = azurerm_mysql_flexible_server.project.name
}

output "mysql_hostname" {
  value = azurerm_mysql_flexible_server.project.fqdn
}

output "wordpress_database_name" {
  value = azurerm_mysql_flexible_database.wordpress.name
}
