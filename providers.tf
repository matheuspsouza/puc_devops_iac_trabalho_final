terraform {
  required_version = ">=0.12"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {

  features {}

  # client_id       = var.client_id
  # client_secret   = var.azure_client_secret
  # subscription_id = var.azure_subscription_id
  # tenant_id       = var.azure_tenant_id

}
