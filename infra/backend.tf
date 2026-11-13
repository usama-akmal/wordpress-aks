terraform {
  backend "azurerm" {
    resource_group_name  = "rg-final-project"
    storage_account_name = "sttf36536035c2eb1aaa"
    container_name       = "tfstate"
    key                  = "infrastructure.tfstate"

    use_azuread_auth = true
    use_cli          = true
  }
}
