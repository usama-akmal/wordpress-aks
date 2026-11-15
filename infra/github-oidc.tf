resource "azurerm_user_assigned_identity" "github_actions" {
  name                = "id-wordpress-github-actions"
  resource_group_name = data.azurerm_resource_group.project.name
  location            = var.location
}

resource "azurerm_federated_identity_credential" "github_main" {
  name                      = "github-main"
  user_assigned_identity_id = azurerm_user_assigned_identity.github_actions.id
  issuer                    = "https://token.actions.githubusercontent.com"
  audience                  = ["api://AzureADTokenExchange"]
  subject                   = "repo:usama-akmal@19644550/wordpress-aks@1456622760:ref:refs/heads/main"
}

resource "azurerm_role_assignment" "github_acr_push" {
  scope                = azurerm_container_registry.project.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.github_actions.principal_id
  principal_type       = "ServicePrincipal"
}

output "github_actions_client_id" {
  description = "Client ID for GitHub Actions OIDC login."
  value       = azurerm_user_assigned_identity.github_actions.client_id
}
