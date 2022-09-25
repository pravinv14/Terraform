# Introduction 
TODO: Create a Azure DevOps pipeline for deploying Azure resource using IaC tool Terraform.

# Getting Started

1.	Prerequisite
2.  Manual creation of certain resource in Azure subscription for Azure DevOps agent and TF backend

# Build and Test
1. Prerequisites
    We need a Visual Studio Professional subscription (VSPS) which will enable us to consume $50 each month.
    I am fortunate enough to work in a company where they provide access to VSPS subscription.
    
    Login to https://my.visualstudio.com/ to activate the VSPS subscription benifits and also activate Azure DevOps.

2. Manual creation of certain resource in Azure subscription for Azure DevOps agent and TF backend

    Head over to Azure Portal and create a ubuntu VM with size "Standard_B1s" use all basic settings which will help us in hosting Azure DevOps Self-Hosted agent.

    also we need a Storage account to store terraform Backend settings like TF state file
    
    # Follow below command

    1) az login --tenant "s893jsk2920-289290-28393"
    2) az account set --subscription "i3kdo93m-2dkdkdkdk-2828292"


    # Set Variables for Storage account and Key Vault that support the Terraform implementation
    1) RESOURCE_GROUP_NAME=your-rg
    2) STORAGE_ACCOUNT_NAME=yoursa
    3) CONTAINER_NAME=tfstatecontainer
    4) STATE_FILE="dev.file.state"

    # Create resource group
    az group create --name $RESOURCE_GROUP_NAME --location eastus

    # Create storage account
    az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

    # Get storage account key (Only used if SPN not available)
    ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)

    # Create blob container
    az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

    Echo details
    1) echo "storage_account_name: $STORAGE_ACCOUNT_NAME" 
    2) echo "container_name: $CONTAINER_NAME" 
    3) echo "access_key: $ACCOUNT_KEY"
    4) echo "state_file: $STATE_FILE" 

    # Create KeyVault and example for storing a key
    1) az keyvault create --name "examplekv" --resource-group $RESOURCE_GROUP_NAME --location eastus
    2) az keyvault secret set --vault-name "examplekv" --name "tfstateaccess" --value {$ACCOUNT_KEY}
    3) az keyvault secret show --vault-name "examplekv" --name "tfstateaccess"