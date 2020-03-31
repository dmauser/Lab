<#Pre-requesits:
- Install Azure Powershell Module (http://aka.ms/azps)
- For now only Powershell 5.1 supported.
- Create a Storage Account and Container in the same Resource Group as VPN Gateway.
#>

Connect-AzAccount
$SubID = (Get-AzSubscription | Out-GridView -Title "Select Subscription ..."-PassThru )
Set-AzContext -Subscription $SubID.name
$RG = (Get-AzResourceGroup | Out-GridView -Title "Select an Azure Resource Group ..." -PassThru ).ResourceGroupName
$VNG = (Get-AzVirtualNetworkGateway -ResourceGroupName $RG).Name | Out-GridView -Title "Select an Azure VNET Gateway ..." -PassThru
$storeName = (Get-AzStorageAccount -ResourceGroupName $RG | Out-GridView -Title "Select an Azure Storage Account ..." -PassThru ).StorageAccountName
$key = Get-AzStorageAccountKey -ResourceGroupName $RG -Name $storeName
$context = New-AzStorageContext -StorageAccountName $storeName -StorageAccountKey $key[0].Value
$containerName = (Get-AzStorageContainer -Context $context | Out-GridView -Title "Select Container Name..." -PassThru ).Name
$now=get-date
$sasurl = New-AzStorageContainerSASToken -Name $containerName -Context $context -Permission "rwd" -StartTime $now.AddHours(-1) -ExpiryTime $now.AddDays(1) -FullUri
$minutes = 5, 7, 15, 20 | Out-Gridview -Title "How many Minutes network capture should run?" -OutputMode Single
$seconds = 60*$minutes

#Start packet capture for a VPN gateway
Write-Host "Starting capture for $VNG Azure VPN Gateway" -ForegroundColor Magenta
Start-AzVirtualnetworkGatewayPacketCapture -ResourceGroupName $RG -Name $VNG
Start-Sleep -Seconds $seconds
Write-Host "Wait about $minutes minutes as capture is running on $VNG Azure VPN Gateway" -ForegroundColor Red
#Stop packet capture for a VPN gateway
Stop-AzVirtualNetworkGatewayPacketCapture -ResourceGroupName $RG -Name $VNG -SasUrl $sasurl
#Script finished
Write-Host "Process has been completed - Use Storage Explorer and download $VNG network captures on $containerName inside Storage Account $storeName" -ForegroundColor Magenta