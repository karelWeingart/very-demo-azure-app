terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.97.1"
    }
  }
  backend "azurerm" {
      resource_group_name  = "tfstate"
      storage_account_name = "tfstate13093"
      container_name       = "tfstate"
      key                  = "test/terraform.tfstate"
  }
}

provider "azurerm" {
  skip_provider_registration = false
  
  features {}
}
