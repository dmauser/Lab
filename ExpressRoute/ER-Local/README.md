# Deploying Local SKU ExpressRoute Circuits

## Contents

[Introduction](#introduction)

[What is ExpressRoute Local SKU](#what-is-expressroute-local-sku)

[Deploy ER Local using Custom Template over Azure Portal](#deploy-er-local-using-custom-template-over-azure-portal)

[Deploy ER Local using ARM Template via Powershell](#deploy-er-local-using-arm-template-via-powershell)

[Change existing ExpressRoute Circuit SKU from Premium or Standard to Local](#change-existing-expressroute-circuit-sku-from-premium-or-standard-to-local)

[Validation of ER Local using Powershell](#validation-of-er-local-using-powershell)

[LAB1 - Deploy a new Local SKU ExpressRoute Circuit](#lab1---deploy-a-new-local-sku-expressroute-circuit)

[LAB2 - Change a current ER Circuit Standard SKU Circuit to Local SKU](#lab2---change-a-current-er-circuit-standard-sku-circuit-to-local-sku)

[Summary](#summary)

## Introduction

In this post we're going go over how to deploy ExpressRoute (ER) LOCAL SKU over the Portal or Powershell by using ARM Templates. It also includes a sample parameter file that you can leverage in case you need automate deployment process. On the second session covers how to you change your existing ExpressRoute circuit to LOCAL SKU. We made available also two LABs to practice the deployment in your own subscription.

## What is ExpressRoute Local SKU

ER Local SKU is a new offering that allow customers with ExpressRoute on a Peering Location close an Azure Region have unlimited egress from Azure to their On-Premises networks. It is important to check which peering location offers ExpressRoute SKU. For more details check: [ExpressRoute connectivity providers](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-locations-providers). Check for the column **Local Azure regions** to validate Location and respective Azure Datacenter is eligible for Local.

<img src="./Peering-Location-Local.png" alt="Peering Location"
title="Peering Location" width="820" height="442" />

For example, Amsterdam and Amsterdam2 are Edge Locations close to West Europe Datacenter. Customer with ExpressRoute only linked VNETs on West Europe Datacenter are eligible to ExpressRoute Local. In the other way around Atlanta does not have a close Azure Regions and customer's with ExpressRoute on that Peering location are not eligible for Local.

**Note:** There are also couple constrains when you use ExpressRoute Local SKU, please review that documentation carefully before you try to make any change.

- For more information about ExpressRoute Local consult: [ExpressRoute Local FAQ](http://aka.ms/ErLocal)
- Local SKU pricing information under is Unlimited Data Plan section at [ExpressRoute Local Pricing](http://aka.ms/ErPricing)

## Deploy ER Local using Custom Template over Azure Portal

You can use Azure Portal or the following ARM Template to deploy ER Local:

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdmauser%2Flab%2Fmaster%2FExpressRoute%2FER-Local%2FER-LOCAL-Circuit.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fdmauser%2Flab%2Fmaster%2FExpressRoute%2FER-Local%2FER-LOCAL-Circuit.json)

Few remarks about this template:

1. You need to enter exact **Provider name, Peering Location and Bandwidths offered**. Use either one the following commands to get those values:

    - Powershell: **Get-AzExpressRouteServiceProvider** 
    - CLI: **az network express-route list-service-providers**

2. At this time this template does not support ER Direct but ER Circuits provisioned over Service Providers.

3. ExpressRoute is deployed as Metered and not Unlimited because for LOCAL SKU is considered unlimited but leaving this parameter as metered makes you opportunity to change to Standard Metered and Premium Metered. Changing to Unlimited will not give you that flexibility because you cannot change from Unlimited back to Metered.

**In summary:**
- **SKU Tier** determines whether and ExpressRoute circuit is Local, Standard and Premium. You can change between and without Circuit downtime.

- **SKU Family** determines billing type and can set to Metered (Meteredata) or Unlimited (Unlimiteddata). You can change from Metered to Unlimited without circuit downtime but you cannot switch back after that. The only way is by recreating the ER circuit.

## Deploy ER Local using ARM Template via Powershell

In this example you deploy same template above but adding parameters on ER-LOCAL-Circuit-Parameters.json. This file has already the parameters populated for your reference. Please, make necessary changes for you needs.

```PowerShell
#1. (Optional) Confirm that you have the correct Subscription before run the commands below:
Get-AzContext
Set-AzContext -Subscription <ExpressRoute Subscription Name>

#2. Set Parameters
$RG = "<Resource-Group>"
$Template = "https://raw.githubusercontent.com/dmauser/Lab/master/ExpressRoute/ER-Local/ER-LOCAL-Circuit.json"
$Parameters = "ER-LOCAL-Circuit-Parameters.json" #Download and make your own changes and update path + file location.

#3. Deploying ER Local Circuit
New-AzResourceGroupDeployment -ResourceGroupName $RG -TemplateURI $Template -TemplateParameterFile $Parameters
```

Another way is to specify all parameters on Powershell command line which by taken all parameters inside ER-LOCAL-Circuit-Parameters.json the command would be:

```powershell
#1. Set Parameters
$RG = "<Replace with Resource-Group Name>"
$Template = "https://raw.githubusercontent.com/dmauser/Lab/master/ExpressRoute/ER-Local/ER-LOCAL-Circuit.json"

#3. Deploying ER Local Circuit
New-AzResourceGroupDeployment -ResourceGroupName $RG `
-TemplateURI $Template `
-circuitName 'Chicago-ER-Local' `
-serviceProviderName 'Megaport' `
-peeringLocation 'Chicago' `
-bandwidthInMbps '1000' `
-location 'northcentralus' `
-sku_tier 'Local'

```

## Change existing ExpressRoute Circuit SKU from Premium or Standard to Local

This option requires that your circuit has at least 1 Gbps. You can change Circuit SKU Tier (Premium, Standard and Local) without Circuit downtime, for more information consult [Modifying an ExpressRoute circuit](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-howto-circuit-arm#modify).

Over the Portal when you have already an existing ER Circuit as Standard  Local SKU is greyed out. This change can be done over Powershell (demonstrated here) or over CLI.

It is important to note that making this change to Local SKU assumes that your ExpressRoute Circuit is on a location that supports ExpressRoute Local as well as your same circuit is current linked to an ExpressRoute Gateway on supported Azure Region. Example, Chicago location is eligible to Local SKU and my circuit is current linked to ExpressRoute Gateway in North Central US. More information on [What is ExpressRoute Local SKU](#What-is-ExpressRoute-Local-SKU).

Follow the instructions below to change from either Premium or Standard to Local:

```Powershell
#1. Get Circuit info:
$Circuit = Get-AzExpressRouteCircuit -Name "<Replace with ER Circuit Name>" -ResourceGroupName "<Replace with ER Circuit Resource Group>"

#2. Set SKU to Local
$Circuit.Sku.Tier = "Local"
# Commit change:
Set-AzExpressRouteCircuit -ExpressRouteCircuit $Circuit
```

If you want to change it back to Standard or Premium just replace the value $Circuit.Sku.Tier = "Local" to either "Standard" or "Premium"
```Powershell
# Example for Standard
$Circuit.Sku.Tier = "Standard"
# Commit change:
Set-AzExpressRouteCircuit -ExpressRouteCircuit $Circuit
```

**Note:** That change from Local to Standard and Premium can be done easily over the Azure Portal under ExpressRoute Circuit - Configuration blade. (Reminder: there's no downtime expected on SKU Tier change).

## Validation of ER Local using Powershell

```powershell
#1.Get Circuit info:
$Circuit = Get-AzExpressRouteCircuit -Name "<Replace with ER Circuit Name>" -ResourceGroupName "<Replace with ER Circuit Resource Group>"
#2.Dump Current SKU
$Circuit.ServiceProviderProperties.BandwidthInMbps 
$Circuit.Sku.Tier
$Circuit.Sku.Family
```

## LAB1 - Deploy a new Local SKU ExpressRoute Circuit

This is basically same process explained on [Deploy ER Local using ARM Template via Powershell](#Deploy-ER-Local-using-ARM-Template-via-Powershell) but with parameters specified and you can deploy in your own subscription as test.
There's a small change below on $Parameters where I specified the parameters file o Git hub and change on 3 to TemplateParameterURI instead of TemplateParameterFile.

```powershell
#1. (Optional) Confirm that you have the correct Subscription before run the commands below:
Get-AzContext
Set-AzContext -Subscription <ExpressRoute Subscription Name>

#2. Set Parameters
$RG = "ER-LAB-LOCAL"
$Template = "https://raw.githubusercontent.com/dmauser/Lab/master/ExpressRoute/ER-Local/ER-LOCAL-Circuit.json"
$Parameters = "https://raw.githubusercontent.com/dmauser/Lab/master/ExpressRoute/ER-Local/ER-LOCAL-Circuit-Parameters.json"

#3. Creating Resource Group and deploying ER Local Circuit
New-AzResourceGroup -Name $RG -Location 'North Central US'
New-AzResourceGroupDeployment -ResourceGroupName $RG -TemplateURI $Template -TemplateParameterURI $Parameters
```

Expected output after deployment:
![](./Lab1-ER-Local.png)

## LAB2 - Change a current ER Circuit Standard SKU Circuit to Local SKU

1. Create a Standard Circuit to emulate this LAB.

```powershell
#1. Set Parameters
$RG = "ER-LAB-LOCAL"
$Template = "https://raw.githubusercontent.com/dmauser/Lab/master/ExpressRoute/ER-Local/ER-LOCAL-Circuit.json"

#2. Deploying ER Standard Circuit
New-AzResourceGroup -Name $RG -Location 'North Central US' #If you already have Resource Group created on previews LAB, please skip this line.
New-AzResourceGroupDeployment -ResourceGroupName $RG `
-TemplateURI $Template `
-circuitName 'ER-Chicago-Std-Local-Demo' `
-serviceProviderName 'Megaport' `
-peeringLocation 'Chicago' `
-bandwidthInMbps '1000' `
-location 'northcentralus' `
-sku_tier 'Standard'

#3 Dump Circuit relevant info
$Circuit = Get-AzExpressRouteCircuit -Name "ER-Chicago-Std-Local-Demo" -ResourceGroupName $RG
$Circuit.ServiceProviderProperties.BandwidthInMbps 
$Circuit.Sku.Tier
$Circuit.Sku.Family
```

Expected output:
![](./LAB2-ER-Local-Output1.png)

```Powershell
#4 Change SKU Tier to Local
$Circuit.Sku.Tier = "Local"
Set-AzExpressRouteCircuit -ExpressRouteCircuit $Circuit

#5 Revalidate the change to Local
$Circuit = Get-AzExpressRouteCircuit -Name "ER-Chicago-Std-Local-Demo" -ResourceGroupName $RG
$Circuit.ServiceProviderProperties.BandwidthInMbps
$Circuit.Sku.Tier
$Circuit.Sku.Family
```

Expected output:
![](./LAB2-ER-Local-Output2.png)

Over Azure Portal - ExpressRoute -Configuration blade show Local as selected:

<img src="./LAB2-ER-Local-Output3.png" alt="Peering Location"
title="Peering Location" width="900" height="294" />

## Summary

In this guide/lab we went over the process of deploy a new ExpressRoute Circuit using Local SKU via ARM Template or Powershell. Additionally we went over the process to change an existing Circuit from Standard (or Premium) to Local. Two LABs have been made available and you can practice and get familiar with both processes.