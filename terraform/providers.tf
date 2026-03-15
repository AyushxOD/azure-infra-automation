terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  # This line tells Terraform: "Don't try to register every Azure service."
  # For AzureRM Provider v3.x, use this setting:
  skip_provider_registration = true
}