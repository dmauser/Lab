# ExpressRoute Local Deployment

In this short article we're going go over how to deploy ExpressRoute (ER) LOCAL SKU over the Portal or Powershell by using ARM Templates. It also includes a sample parameter file that you can leverage in case you need automate deployment process. There's also a session that shows how to you exisiting ExpressRoute circuit to LOCAL Sku.

## What is ExpressRoute LOCAL?

ER Local is a new offering that allow customers with ExpressRoute on Peering Location closes to Azure Region have unlimited egress from Azure to their On-Premises networks. It is important to check this list page on to check peering location offers ExpressRoute SKU. For more details check:

For more information about ExpressRoute Local consult: [ExpressRoute Local FAQ](http://aka.ms/ErLocal)

**Note:** There are also couple constrains when you use ExpressRoute Local SKU, please review that documentation carefully before you try to make any change.

For pricing information under Unlimited Data Plan section at [ExpressRoute Local Pricing](http://aka.ms/ErPricing)

## Deploy ER Local using Custom Template over Azure Portal

**Special Note**: At the time of this writing you can only create ExpressRoute LOCAL over Azure Portal with circuits over 2Gbps but in reality the requirement is 1Gbps per documentation shared on previous session. Therefore, you can use this ExpressRoute template as workaround until that gets fixed over official Azure Portal. Alternatively your can create a 1Gbps Standard SKU and change SKU to local via Powershell shared on the section below [Change existing ExpressRoute Circuit SKU from Premium or Standard to Local](#Change-existing-ExpressRoute-Circuit-SKU-from-Premium-or-Standard-to-Local).

Use the following ARM Template to deploy ER Local:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdmauser%2Flab%2Fmaster%2FExpressRoute%2FER-Local%2FER-LOCAL-Circuit.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fdmauser%2Flab%2Fmaster%2FExpressRoute%2FER-Local%2FER-LOCAL-Circuit.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Deploy ER Local using ARM Template via Powershell

```PowerShell
#Confirm that you have the correct Subscription before run the commands below:
Get-AzContext
Set-AzContext -Subscription <ExpressRoute Subscription Name>

#Specify Parameters
$RG = "<Resource-Group>"
$Template = "ER-LOCAL-Circuit.json"
$Parameters = "ER-LOCAL-Circuit-Parameters.json"

New-AzResourceGroupDeployment -ResourceGroupName $RG -TemplateFile $Template -TemplateParameterFile $Parameters
```

## Change existing ExpressRoute Circuit SKU from Premium or Standard to Local

This option requires that your circuit has at least 1 Gbps. It is important to mention that is not downtime when making changes on Circuit SKU Tier (Premium, Standard and Local), for more information consult [Modifying an ExpressRoute circuit](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-howto-circuit-arm#modify).

```Powershell
#1. Get Circuit info:
$Circuit = Get-AzExpressRouteCircuit -Name "<Replace ER Circuit Name>" -ResourceGroupName "<ER Circuit Resource Group>"

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

**Note:** That change from Local to Standard and Premium can be done easily over the Azure Portal under ExpressRoute Circuit - Configuration blade. (Again, there's no downtime expected on that SKU change).

## Validation of ER Local using Powershell:
