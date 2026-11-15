resource "azurerm_user_assigned_identity" "wordpress_aks" {
  name                = "id-wordpress-aks"
  resource_group_name = data.azurerm_resource_group.project.name
  location            = var.location
}

resource "azurerm_federated_identity_credential" "wordpress_aks" {
  name                      = "aks-wordpress-service-account"
  user_assigned_identity_id = azurerm_user_assigned_identity.wordpress_aks.id
  issuer                    = "https://eastus2.oic.prod-aks.azure.com/a7a2dc3d-d5f7-4e0c-99a2-48a4c37c37a0/90153d92-a513-47cb-a7d9-a01e34954f5f/"
  audience                  = ["api://AzureADTokenExchange"]
  subject                   = "system:serviceaccount:wordpress:wordpress"
}

resource "azurerm_role_assignment" "wordpress_aks_secret_reader" {
  for_each = toset(["wordpress-db-password", "wordpress-salts"])

  scope                = "${azurerm_key_vault.project.id}/secrets/${each.value}"
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.wordpress_aks.principal_id
  principal_type       = "ServicePrincipal"
}

output "wordpress_aks_client_id" {
  description = "Managed identity client ID for the WordPress service account."
  value       = azurerm_user_assigned_identity.wordpress_aks.client_id
}
