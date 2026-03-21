terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "stdevopsfactorytf"
    container_name       = "tfstate"
    key                  = "devops-factory.tfstate"
  }
}
