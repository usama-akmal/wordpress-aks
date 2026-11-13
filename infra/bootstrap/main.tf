data "azurerm_resource_group" "project" {
  name = "rg-final-project"
}

locals {
  storage_name = "sttf${substr(sha1(data.azurerm_resource_group.project.id), 0, 16)}"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = local.storage_name
  resource_group_name      = data.azurerm_resource_group.project.name
  location                 = data.azurerm_resource_group.project.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }
  }

  tags = {
    project = "wordpress-aks"
    purpose = "terraform-state"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}
