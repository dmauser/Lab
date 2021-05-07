# ARM Template to deploy Azure VPN gateway with APIPA

## Concepts

1. This template deploys Active-Active Azure VPN Gateway with APIPA and can be provisioned also over CLI and Powershell.
2. This script requires Virtual Network and Gateway Subnet previous created.

## Parameters

- **gatewayName** **(required)** - VPN gateway name. 
- **gatewaySku** **(required)** - gateway size. Allowed values: VpnGw1 (default), VpnGw2, VpnGw3, VpnGw4, VpnGw5).
- **vnetName** **(required)** -  existing virtual network name.
- **active-active** - Disable (default) deploys VPN Gateway as Active/Passive. Enabled Deploys VPN Gateway as Active/Active.
- **vpnGatewayGeneration** (optional) specify VPN gateway generation. Allowed values Generation1 (default) or Generation2.
- **asn** (optional) BGP AS number (default: 65515)
- **customBgpIpAddresses1** (optional) custom BGP APIPA address for first VPN gateway instance (default 169.254.21.2).
- **customBgpIpAddresses2** (optional) custom BGP APIPA address for second VPN gateway instance (default 169.254.21.4).

Please note that optional values not specified during deployment will default to their respective values. Also, keep in mind they are case sensitive when using bash (Enabled is different from enabled).

## Portal

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdmauser%2FLab%2Fmaster%2FVNG-APIPA%2Fvng-apipa.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fdmauser%2FLab%2Fmaster%2FVNG-APIPA%2Fvng-apipa.json)

## CLI

**Example 1** - Deploy A/A VPN Gateway and specify APIPA BGP for both instances on exiting VNET:

```bash
#variables
hubname=Hub #deploy VNG on Hub
rg=Lab-vngapipa #specify resource group name
vnetname=$hubname-vnet #Existing VNET name on Lab-vngapipa resource group.

az deployment group create --name $hubname-vpngw --resource-group $rg \
--template-uri "https://raw.githubusercontent.com/dmauser/Lab/master/VNG-APIPA/vng-apipa.json" \
--parameters gatewayName=$hubname-vpngw gatewaySku=VpnGw1 active-active=enabled vnetName=$vnetname customBgpIpAddresses1=169.254.21.2 customBgpIpAddresses2=169.254.21.4 \
--no-wait
```

**Example 2** - Deploy A/A VPN Gateway and specify APIPA BGP on new VNET:

```bash
#variables
#variables
rg=Lab-vngapipa #specify resource group name
vnetname=hub-vnet #VNET name on Lab-vngapipa resource group.
location=southcentralus #specify Azure region
vnetcidr="10.0.0.0/24"
GatewaySubnet="10.0.0.0/28"

#Commands to deploy
az group create --name $rg --location $location --output none
az network vnet create --resource-group $rg --name $vnetname --location $location --address-prefixes $vnetcidr --subnet-name GatewaySubnet --subnet-prefix $GatewaySubnet
az deployment group create --name $rg-vpngw --resource-group $rg \
--template-uri "https://raw.githubusercontent.com/dmauser/Lab/master/VNG-APIPA/vng-apipa.json" \
--parameters gatewayName=vpngw gatewaySku=VpnGw1 activeActive=Enabled vnetName=$vnetname customBgpIPAddresses_1=169.254.21.2 customBgpIPAddresses_2=169.254.21.4 \
--no-wait
```

## PowerShell

Example of deploying over Powershell VPN Gateway Active-Active over existing VNET:

```Powershell
$RG = "LAB" #Resource Group
$Template = "https://raw.githubusercontent.com/dmauser/Lab/master/VNG-APIPA/vng-apipa.json"
New-AzResourceGroupDeployment -ResourceGroupName $RG -TemplateParameterUri $Template `
-gatewayName "vpngw" `
-gatewaySku "VpnGw1" `
-vnetName "vNetName" `
-active-active "Enabled" `
-asn "65001"
```
