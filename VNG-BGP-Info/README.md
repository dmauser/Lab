# Script to obtain BGP information from Azure VPN and ExpressRoute Gateways

## Introduction

This is simple script that dump all BGP routing information for VPN or ExpressRoute Virtual Network Gateways (VNG). Please note, this script is not applicable for Virtual WAN VPN or ExpressRoute Gateways. 

## Known issues

1) **ExpressRoute Gateway** - This script is unable to retrieve learned routes from ExpressRoute Gateways but it is capable to dump BGP peering status and advertised routes. There's a current support ticket in Support to address this issue.
2) **VPN Gateway** - On Active-Active setups and Point to Site enabled it takes a long time to dump BGP peers.

## Script usage ad content

Script is available inside the repository as VNG-BGP-Info.ps1 or save the content listed below. It only works as saved as script because it requires you to specify parameters before running it.

### Usage
VNG-BGP-Info.ps1 -GatewayName VNGName -ResourceGroupName RGName   

### Script content
```PowerShell
#List All Virtual Network Gateways for current Subscription
#BGP Routing info for Virtual Network Gateway (ExpressRoute or VPN)

Param(
    [Parameter(Mandatory=$true,
    HelpMessage="Add ExpressRoute or VPN Gateway Name")]
    [String]
    $GatewayName,

    [Parameter(Mandatory=$true,
    HelpMessage="Add Resource Group ExpressRoute or VPN Virtual Network Gateway")]
    [String]
    $ResourceGroupName
)

# Shows Peer Connections State, Routes Received, BGP Messages send and received
Write-Host "BGP peering connection status" -ForegroundColor Yellow
$Peerinfo = Get-AzVirtualNetworkGatewayBGPPeerStatus -ResourceGroupName $ResourceGroupName  -VirtualNetworkGatewayName $GatewayName
$Peerinfo | Format-Table

#Shows all routes learned by VNG
Write-Host "Learned routes by" $GatewayName -ForegroundColor Yellow
Get-AzVirtualNetworkGatewayLearnedRoute -ResourceGroupName $ResourceGroupName -VirtualNetworkGatewayName $GatewayName | Format-Table

#Shows all routes advertised by VNG
$ValidPeerInfo = $Peerinfo | Where-Object State -Like "Connected"
Write-Host $GatewayName "advertised routes for each BGP Peer:"  -ForegroundColor Yellow

foreach ($Peer in $ValidPeerinfo.Neighbor) {
    Write-Host "Advertised routes to BGP Peer" $Peer -ForegroundColor Yellow
    Get-AzVirtualNetworkGatewayAdvertisedRoute -ResourceGroupName $ResourceGroupName -VirtualNetworkGatewayName $GatewayName -peer $Peer | Format-Table
}
```
## LAB

1) Deploy template two Azure VPN Gateways using BGP using this ARM template[VNET to VNET connection](https://github.com/Azure/azure-quickstart-templates/tree/master/201-vnet-to-vnet-bgp).
2) Run the script above against both VNG Gateways to get information about BGP Peering.

***Expected Output***
