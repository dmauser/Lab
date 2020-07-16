# Deploying Local SKU ExpressRoute Circuits

In this post we're going go over how to deploy ExpressRoute (ER) LOCAL SKU over the Portal or Powershell by using ARM Templates. It also includes a sample parameter file that you can leverage in case you need automate deployment process. On the second session covers how to you change your existing ExpressRoute circuit to LOCAL SKU. We made available also two LAB sessions to practice the deployment in your own subscription.

## What is ExpressRoute LOCAL

ER Local is a new offering that allow customers with ExpressRoute on Peering Location closes to Azure Region have unlimited egress from Azure to their On-Premises networks. It is important to check this list page on to check peering location offers ExpressRoute SKU. For more details check: [ExpressRoute connectivity providers](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-locations-providers). Check for the column **Local Azure regions** to check if your Location and respective Azure Datacenter is eligible for Local.


 Example, Amsterdam and Amsterdam2 are Edge Locations close to West Europe Datacenter. Customer with ExpressRoute only linked reaching VNETs on West Europe Datacenter are eligible to ExpressRoute Local. In the other way around Atlanta does not have a close Azure Regions customer's with Peering to that Edge location are not eligible for Local:


For more information about ExpressRoute Local consult: [ExpressRoute Local FAQ](http://aka.ms/ErLocal)

**Note:** There are also couple constrains when you use ExpressRoute Local SKU, please review that documentation carefully before you try to make any change.
For pricing information under Unlimited Data Plan section at [ExpressRoute Local Pricing](http://aka.ms/ErPricing)

## Deploy ER Local using Custom Template over Azure Portal

**Special Note**: At the time of writing this guide it is only allowed to create ExpressRoute LOCAL over Azure Portal with circuits over 2 Gbps but in reality the requirement is 1 Gbps per documentation (see links above). Therefore, you can use this ExpressRoute template as workaround until that gets fixed over official Azure Portal. Alternatively your can create a 1 Gbps Standard SKU and change SKU to local via Powershell shared on the section below [Change existing ExpressRoute Circuit SKU from Premium or Standard to Local](#Change-existing-ExpressRoute-Circuit-SKU-from-Premium-or-Standard-to-Local).

Use the following ARM Template to deploy ER Local:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdmauser%2Flab%2Fmaster%2FExpressRoute%2FER-Local%2FER-LOCAL-Circuit.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fdmauser%2Flab%2Fmaster%2FExpressRoute%2FER-Local%2FER-LOCAL-Circuit.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Few remarks about this template:

1. You need to enter exact Provider name, Peering Location and Bandwidths offered. Use either one the following commands:

- Powershell: **Get-AzExpressRouteServiceProvider** 
- CLI: **az network express-route list-service-providers**

2. At this time this template does not support ER Direct but ER Circuits provisioned over Service Providers.
3. ExpressRoute is deployed as Metered and not Unlimited because for LOCAL SKU is considered unlimited but leaving this parameter as metered makes you opportunity to change to Standard Metered and Premium Metered. Changing to Unlimited will not give you that flexibility because you cannot change from Unlimited back to Metered.

In summary:
- SKU Tier determines whether and ExpressRoute circuit is Local, Standard and Premium. You can change between and no Circuit downtime
- SKU Family determines billing type and can set to Metered (Metereddata) or Unlimited (Unlimiteddata). You can change from Metered to Unlimited (no downtime) but you cannot switch back after that. The only way is recreating the ER circuit.

## Deploy ER Local using ARM Template via Powershell

In this example you deploy same template but already adding parameters on ER-LOCAL-Circuit-Parameters.json. This file has already the parameters populated for your reference. Please, make necessary changes you needs.

```PowerShell
#1. (Optional) Confirm that you have the correct Subscription before run the commands below:
Get-AzContext
Set-AzContext -Subscription <ExpressRoute Subscription Name>

#2. Specify Parameters
$RG = "<Resource-Group>"
$Template = "https://raw.githubusercontent.com/dmauser/Lab/master/ExpressRoute/ER-Local/ER-LOCAL-Circuit.json"
$Parameters = "ER-LOCAL-Circuit-Parameters.json" #Download and make your own changes and update path + file location.

#3. Deploy ER Local Circuit
New-AzResourceGroupDeployment -ResourceGroupName $RG -TemplateURI $Template -TemplateParameterFile $Parameters
```
Another way is to specify all parameters on Powershell command line which by taken all parameters inside ER-LOCAL-Circuit-Parameters.json the command would be:

```powershell
#1. Specify Parameters
$RG = "<Replace with Resource-Group Name>"
$Template = "https://raw.githubusercontent.com/dmauser/Lab/master/ExpressRoute/ER-Local/ER-LOCAL-Circuit.json"

#3. Deploy ER Local Circuit
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

This option requires that your circuit has at least 1 Gbps. It is important to mention that is not downtime when making changes on Circuit SKU Tier (Premium, Standard and Local), for more information consult [Modifying an ExpressRoute circuit](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-howto-circuit-arm#modify).

Over the Portal when you have already an existing ER Circuit as Standard there's the Local SKU is greyed out. This change can be done over Powershell (demonstrated here) or over CLI. Follow the instructions below:

```Powershell
#1. Get Circuit info:
$Circuit = Get-AzExpressRouteCircuit -Name "<Replace with ER Circuit Name>" -ResourceGroupName "<Replace with ER Circuit Resource Group>"

#2. #Set SKU to Local
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

## Validation of ER Local using Powershell:

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

#2. Specify Parameters
$RG = "ER-LAB-LOCAL"
$Template = "https://raw.githubusercontent.com/dmauser/Lab/master/ExpressRoute/ER-Local/ER-LOCAL-Circuit.json"
$Parameters = "https://raw.githubusercontent.com/dmauser/Lab/master/ExpressRoute/ER-Local/ER-LOCAL-Circuit-Parameters.json"

#3. Creating Resource Grop and Deploy ER Local Circuit
New-AzResourceGroup -Name $RG -Location 'North Central US'
New-AzResourceGroupDeployment -ResourceGroupName $RG -TemplateURI $Template -TemplateParameterURI $Parameters
```

## LAB2 - Change a current ER Circuit Standard SKU Circuit to Local SKU

1. Create a Standard Circuit to emulate this LAB.

```powershell
#1. Specify Parameters
$RG = "ER-LAB-LOCAL"
$Template = "https://raw.githubusercontent.com/dmauser/Lab/master/ExpressRoute/ER-Local/ER-LOCAL-Circuit.json"

#2. Deploy ER Standard Circuit
New-AzResourceGroup -Name $RG -Location 'North Central US' #If you already have Resource Group created on previews LAB, please skip this line.
New-AzResourceGroupDeployment -ResourceGroupName $RG `
-TemplateURI $Template `
-circuitName '' `
-serviceProviderName 'Megaport' `
-peeringLocation 'Chicago' `
-bandwidthInMbps '1000' `
-location 'northcentralus' `
-sku_tier 'Standard'

#3 Dump Circuit relevant info
$Circuit = Get-AzExpressRouteCircuit -Name "Chicago-ER-STD-to-Local" -ResourceGroupName $RG
$Circuit.ServiceProviderProperties.BandwidthInMbps 
$Circuit.Sku.Tier
$Circuit.Sku.Family

#4 Change SKU Tier to Local
$Circuit.Sku.Tier = "Local"
Set-AzExpressRouteCircuit -ExpressRouteCircuit $Circuit

#5 Revalidate the change to Local
$Circuit = Get-AzExpressRouteCircuit -Name "Chicago-ER-STD-to-Local" -ResourceGroupName $RG
$Circuit.ServiceProviderProperties.BandwidthInMbps
$Circuit.Sku.Tier
$Circuit.Sku.Family

```

## Summary

In this guide/lab we went over the process of deploy a new ExpressRoute Circuit using Local SKU via ARM Template or Powershell. Additionally we went over the process to change an existing Circuit from Standard (or Premium) to Local. Two LABs have been made available and you can practice and get familiar with both processes.