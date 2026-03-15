terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatecentral1773573864" # Replace with your actual name
    container_name       = "remote-state"
    key                  = "terraform.tfstate"
  }
}