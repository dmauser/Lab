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