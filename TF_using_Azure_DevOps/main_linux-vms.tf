# log analytic workspace, resource group, vnet and subnet as per the module needs to be available in subscription to get this working  
# Azurerm provider configuration
terraform {
  backend "azurerm" {
        resource_group_name  = "example-rg"
        storage_account_name = "example"
        container_name       = "tfstatecontainer"
        key                  = "example.tfstate"
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

data "azurerm_log_analytics_workspace" "example" {
  name                = "loganalytics-sharedtest3"
  resource_group_name = "rg-shared-eastus-01"
}

module "virtual-machine" {
  source  = "kumarvna/virtual-machine/azurerm"
  version = "2.3.0"

  # Resource Group, location, VNet and Subnet details
  resource_group_name  = "rg-shared-eastus-01"
  location             = "eastus"
  virtual_network_name = "vnet-shared-hub-eastus-001"
  subnet_name          = "snet-management"
  virtual_machine_name = "vm-linux"

  # This module support multiple Pre-Defined Linux and Windows Distributions.
  # Check the README.md file for more pre-defined images for Ubuntu, Centos, RedHat.
  # Please make sure to use gen2 images supported VM sizes if you use gen2 distributions
  # Specify `disable_password_authentication = false` to create random admin password
  # Specify a valid password with `admin_password` argument to use your own password 
  # To generate SSH key pair, specify `generate_admin_ssh_key = true`
  # To use existing key pair, specify `admin_ssh_key_data` to a valid SSH public key path.  
  os_flavor               = "linux"
  linux_distribution_name = "ubuntu2004"
  virtual_machine_size    = "Standard_B1s"
  generate_admin_ssh_key  = true
  instances_count         = 20

  # Proxymity placement group, Availability Set and adding Public IP to VM's are optional.
  # remove these argument from module if you dont want to use it.  
  enable_proximity_placement_group = false
  enable_vm_availability_set       = false
  enable_public_ip_address         = false

  # Network Seurity group port allow definitions for each Virtual Machine
  # NSG association to be added automatically for all network interfaces.
  # Remove this NSG rules block, if `existing_network_security_group_id` is specified
  nsg_inbound_rules = [
    {
      name                   = "ssh"
      destination_port_range = "22"
      source_address_prefix  = "*"
    }
  ]

  # Boot diagnostics to troubleshoot virtual machines, by default uses managed 
  # To use custom storage account, specify `storage_account_name` with a valid name
  # Passing a `null` value will utilize a Managed Storage Account to store Boot Diagnostics
  enable_boot_diagnostics = false

  # Attach a managed data disk to a Windows/Linux VM's. Possible Storage account type are: 
  # `Standard_LRS`, `StandardSSD_ZRS`, `Premium_LRS`, `Premium_ZRS`, `StandardSSD_LRS`
  # or `UltraSSD_LRS` (UltraSSD_LRS only available in a region that support availability zones)
  # Initialize a new data disk - you need to connect to the VM and run diskmanagemnet or fdisk
  # data_disks = [
  #   {
  #     name                 = "disk1"
  #     disk_size_gb         = 100
  #     storage_account_type = "StandardSSD_LRS"
  #   },
  #   {
  #     name                 = "disk2"
  #     disk_size_gb         = 200
  #     storage_account_type = "Standard_LRS"
  #   }
  # ]

  # (Optional) To enable Azure Monitoring and install log analytics agents
  # (Optional) Specify `storage_account_name` to save monitoring logs to storage.   
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.example.id

  # Deploy log analytics agents to virtual machine. 
  # Log analytics workspace customer id and primary shared key required.
  deploy_log_analytics_agent                 = false
  log_analytics_customer_id                  = data.azurerm_log_analytics_workspace.example.workspace_id
  log_analytics_workspace_primary_shared_key = data.azurerm_log_analytics_workspace.example.primary_shared_key

  # Adding additional TAG's to your Azure resources
  tags = {
    ProjectName  = "demo-project"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
}
