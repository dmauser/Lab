# ARM Template to deploy Azure VPN gateway with APIPA

## Concepts

1. This template deploys Active-Active Azure VPN Gateway with APIPA to help provisioning on automated labs.
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

Please note that optional values not specified during deployment will default to their respective values.

## Portal

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdmauser%2FLab%2Fmaster%2FVNG-APIPA%2Fvng-apipa.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fdmauser%2FLab%2Fmaster%2FVNG-APIPA%2Fvng-apipa.json)

## CLI

Example of CLI command to deploy A/A VPN Gateway and specify APIPA BGP for both instances:

```bash
#variables
$hubname=Hub #deploy VNG on Hub
$rg=Lab #specify resource group name

az deployment group create --name $hubname-vpngw --resource-group $rg \
--template-uri "https://raw.githubusercontent.com/dmauser/Lab/master/VNG-APIPA/vng-apipa.json" \
--parameters gatewayName=$hubname-vpngw gatewaySku=VpnGw1 active-active=enabled vnetName=$hubname-vnet customBgpIpAddresses1=169.254.21.2 customBgpIpAddresses2=169.254.21.4 \
--no-wait
```

## PowerShell

Example of deploying over Powershell:

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
