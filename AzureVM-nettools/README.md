# LAB

#### In this article

[Concepts](#Concepts)

[Scenario 1: Deploy a new Azure Linux VM with Network Tools using CLI](#Scenario-1:-Deploy-a-new-Azure-Linux-VM-with-Network-Tools-using-CLI)

[Scenario 2: Install network utilities on your existing Linux VMs](#Scenario-2:-Install-network-utilities-on-your-existing-Linux-VMs)

## Concepts

This is a quick lab to show you how to deploy networking utilities/tools on your Linux VM. (Windows coming soon)
Please review the list of network tools installed inside the content of the [script](https://raw.githubusercontent.com/dmauser/Lab/master/AzureVM-nettools/nettools.sh). You can also define your own startup script and replace the script URL on the variable nettoolsuri listed on the examples below.

It is important to note all procedures below have been tested on Linux Ubuntu 18.04. You may need to make changes depending on your Linux distro.

### Requirements

- [Azure Cloud Shell](https://shell.azure.com/)
- Ubuntu Linux or WLS using Azure CLI (curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash). More info [Install the Azure CLI on Linux](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt).

**Note:**: an Azure Shell script [lxvm-nettools.azcli](https://raw.githubusercontent.com/dmauser/Lab/master/AzureVM-nettools/lxvm-nettools.azcli) with the scenarios below are also included in this repo.

## Scenario 1: Deploy a new Azure Linux VM with Network Tools using CLI

```Bash
# Define variables
rg=LAB-NetTools ## Define your resource group
location=southcentralus # Define your location
vnetname=AzureVNET # Azure VNET name
vmname=AzVM1 # Azure VM Name
username=azureadmin
nettoolsuri="https://raw.githubusercontent.com/dmauser/Lab/master/AzureVM-nettools/nettools.sh"

# Create VNET/Subnet
az group create --name $rg --location $location
az network vnet create --resource-group $rg --name $vnetname --location $location \
--address-prefixes 10.0.0.0/24 \
--subnet-name subnet1 \
--subnet-prefix 10.0.0.0/24

# Create VM using
az network public-ip create --name $vmname-pip --resource-group $rg --location $location --sku Basic --allocation-method Dynamic
az network nic create --resource-group $rg -n $vmname-nic --location $location \
--subnet subnet1 \
--vnet-name $vnetname \
--public-ip-address $vmname-pip
az vm create -n $vmname --resource-group $rg --size Standard_B1s --image UbuntuLTS \
--admin-username $username \
--nics $vmname-nic \
--generate-ssh-keys

## Run Extension Script
az vm extension set \
--resource-group $rg \
--vm-name $vmname \
--name customScript \
--publisher Microsoft.Azure.Extensions \
--protected-settings "{\"fileUris\": [\"$nettoolsuri\"],\"commandToExecute\": \"./nettools.sh\"}" \
--no-wait

## Obtain Public IP and ssh to the target machine.
pip=$(az network public-ip show --name $vmname-pip --resource-group $rg --query ipAddress -o tsv)
# ssh to the VM and test the tools are present (traceroute and others)
ssh azureadmin@$pip
# 1) Run traceroute
# 2) Run curl localhost and you should see your VM name.
```

## Scenario 2: Install network utilities on your existing Linux VMs

Install network utilities on all Linux VMs inside a resource group.

```Bash
# Define variables
rg=RSLAB-EUS2-AZFW ## Define your resource group
nettoolsuri="https://raw.githubusercontent.com/dmauser/Lab/master/AzureVM-nettools/nettools.sh"

# Loop below will list all your Linux VMs and install the network utilities on them.
for vm in `az vm list -g $rg --query "[?storageProfile.osDisk.osType=='Linux'].name" -o tsv`
do
    az vm extension set \
    --resource-group $rg \
    --vm-name $vm \
    --name customScript \
    --publisher Microsoft.Azure.Extensions \
    --protected-settings '{"fileUris": ["$nettoolsuri"],"commandToExecute": "./nettools.sh"}' \
    --no-wait
done
```