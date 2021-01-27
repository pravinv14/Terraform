# Configure the Microsoft Azure Provider
provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x.
    # If you're using version 1.x, the "features" block is not allowed.
    version = "2.44"
    features {}
    #Below details are for accesing the azure portal using Service principle
    subscription_id = "SubscriptionID"
    client_id       = "ClientID"
    client_secret   = "Client_secret"
    tenant_id       = "TenantID"
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "MyRG" {
    name     = "Resource group Name"
    location = "Location like Southeast Asia"

    tags = {
        Owner = "Lavakumar"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myvnet" {
    name                = "myvnet name"
    address_space       = ["CIDR like 10.0.0.0/24"]
    location            = "Location like Southeast Asia"
    resource_group_name = azurerm_resource_group.MyRG.name

    tags = {
        Owner = "Lavakumar"
    }
}

# Create subnet
resource "azurerm_subnet" "mysubnet" {
    name                 = "default"
    resource_group_name  = azurerm_resource_group.MyRG.name
    virtual_network_name = azurerm_virtual_network.myvnet.name
    address_prefixes       = ["CIDR same as Vnet or multiple subnets"]
}

# Create public IPs
resource "azurerm_public_ip" "mypublicip" {
    name                         = "my public-IP"
    location                     = "Location like Southeast Asia"
    resource_group_name          = azurerm_resource_group.MyRG.name
    allocation_method            = "Mention if you need 'Static' or 'Dynamic'"

    tags = {
        Owner = "Lavakumar"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "mynsg" {
    name                = "nsg name"
    location            = "Location like Southeast Asia"
    resource_group_name = azurerm_resource_group.MyRG.name

    security_rule {
        name                       = "NAME OF SECURITY RULE"
        priority                   = 101 OR 1001...
        direction                  = "Inbound OR Outbound"
        access                     = "Allow or Deny"
        protocol                   = "Tcp or Udp or All"
        source_port_range          = "*"
        destination_port_range     = "Port or *"
        source_address_prefix      = "My IP"
        destination_address_prefix = "*"
    }

    tags = {
        Owner = "Lavakumar"
    }
}

# Create network interface
resource "azurerm_network_interface" "mynic" {
    name                      = "nic name"
    location                  = "Location like Southeast Asia"
    resource_group_name       = azurerm_resource_group.MyRG.name

    ip_configuration {
        name                          = "ipconfig-mynic"
        subnet_id                     = azurerm_subnet.mysubnet.id
        private_ip_address_allocation = "Private IP is Dynamic or static"
        public_ip_address_id          = azurerm_public_ip.mypublicip.id
    }

    tags = {
        Owner = "Lavakumar"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.mynic.id
    network_security_group_id = azurerm_network_security_group.mynsg.id
}

# Generate random text for a unique storage account name for storing boot diagnostics
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.MyRG.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.MyRG.name
    location                    = "Location like Southeast Asia"
    account_tier                = "Standard or Premium"
    account_replication_type    = "LRS or ZRS or GRS .."

    tags = {
        Owner = "Lavakumar"
    }
}

# Create (and display) an SSH key
#resource "tls_private_key" "example_ssh" {
  #algorithm = "RSA"
  #rsa_bits = 4096
#}
#output "tls_private_key" { value = tls_private_key.example_ssh.private_key_pem }

# Create virtual machine
resource "azurerm_linux_virtual_machine" "my vm" {
    name                  = "VM Name"
    location              = "Location like Southeast Asia"
    resource_group_name   = azurerm_resource_group.MyRG.name
    network_interface_ids = [azurerm_network_interface.mynic.id]
    size                  = "Standard_DS1_v2 or Standard_B2s or ..."

    os_disk {
        name              = "My Os Disk"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS or StandardSSD_LRS or Premium_LRS "
        disk_size_gb = "50 or Size of O disk"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS or version SKU"
        version   = "latest"
    }

    computer_name  = "VM Name"
    admin_username = "Username for login"
    admin_password = "Password for login"
    disable_password_authentication = false

    #admin_ssh_key {
        #username       = "Username for login"
        #public_key     = tls_private_key.example_ssh.public_key_openssh
    #}

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        Owner = "Lavakumar"
    }
}
