# simple TF code for deploying Azure VNet

###  provider details
terraform {
  backend "azurerm" {
        resource_group_name  = "your-rg"
        storage_account_name = "yoursa"
        container_name       = "tfstatecontainer"
        key                  = "dev.vnet.terraform.tfstate"
    }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

#### variables
variable "resource_group_name" {
  type = string
  default = "rg-tf-test"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vnet_cidr_range" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_prefixes" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "subnet_names" {
  type    = list(string)
  default = ["web", "database"]
}
###

resource "azurerm_resource_group" "vnet_main" {
  name     = var.resource_group_name
  location = var.location
}

module "vnet-main" {
  source              = "Azure/vnet/azurerm"
  version             = "~> 2.0"
  resource_group_name = azurerm_resource_group.vnet_main.name
  vnet_name           = var.resource_group_name
  address_space       = [var.vnet_cidr_range]
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names
  nsg_ids             = {}

  tags = {
    environment = "dev"
  }

  depends_on = [azurerm_resource_group.vnet_main]
}

# OUTPUTS

output "vnet_id" {
  value = module.vnet-main.vnet_id
}
