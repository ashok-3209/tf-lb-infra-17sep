terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.34.0"
    }
  }
   backend "azurerm" {
     tenant_id        = "ba464e9e-9154-4fc0-9582-760e55463849"  
     subscription_id  = "cefa80e5-9af0-4e4a-9f43-e0a0491a5473" 
     resource_group_name  = "ashok-stg-rg"
     storage_account_name = "ashokstgacct01"
     container_name       = "tfstates-container"
     key                  = "dev.tfstate"
    
  }
}

provider "azurerm" {
  features {}
  subscription_id = "cefa80e5-9af0-4e4a-9f43-e0a0491a5473"
}