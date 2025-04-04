terraform {
  backend "azurerm" {
    resource_group_name  = "<Resource_group_name>"
    storage_account_name = "tosavebusbudtfbackend"
    container_name       = "busbud-tf-backend"
    key                  = "terraform.tfstate"
  }
}
