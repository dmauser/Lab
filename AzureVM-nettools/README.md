# LAB

## Create Azure Linux VM - CLI 

```Bash
# Define variables
rg=VMNetTools
location=southcentralus
vnetname=AzureVNET
vmname=AzVM1

# Create VNET/Subnet
az group create --name $rg --location northcentralus
az network vnet create --resource-group $rg --name $vnetname --location northcentralus \ 
--address-prefixes 10.0.0.0/24 \
--subnet-name subnet1 \
--subnet-prefix 10.0.0.0/24

# Create VM using 
az network public-ip create --name $vmname-pip --resource-group $rg --location $location --allocation-method Dynamic
az network nic create --resource-group $rg -n $vmname-nic --location $location \
--subnet subnet1 --private-ip-address 10.0.2.10 \
--vnet-name $vnetname --public-ip-address $vmname-pip
az vm create -n $vmname --resource-group $rg --size Standard_B1s --image UbuntuLTS \ 
--admin-username dmauser \
--ssh-key-values dmauser.pub \
--nics $vmname-nic --no-wait

## Run Extension Script
az vm extension set \
  --resource-group $rg \
  --vm-name $vmname \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --protected-settings '{"fileUris": ["https://raw.githubusercontent.com/dmauser/Lab/master/AzureVM-nettools/nettools.sh"],"commandToExecute": "./nettools.sh"}'

```