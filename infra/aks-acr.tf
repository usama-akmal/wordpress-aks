data "azurerm_user_assigned_identity" "aks_kubelet" {
  name                = "aks-k8s-lab-agentpool"
  resource_group_name = "MC_rg-k8s-lab_aks-_eastus2"
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.project.id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_user_assigned_identity.aks_kubelet.principal_id
  principal_type       = "ServicePrincipal"
}