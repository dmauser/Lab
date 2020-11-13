Param(
    [Parameter(Mandatory=$true,
    HelpMessage="Add ")]
    [String]
    $vWANGWName,

    [Parameter(Mandatory=$true,
    HelpMessage="Add vWAN Resource Group Name")]
    [String]
    $vWANGWRG,

    [Parameter(Mandatory=$true,
    HelpMessage="Add Storage Account Name")]
    [String]
    $StgName,

    [Parameter(Mandatory=$true,
    HelpMessage="Add Storage Account Resource Group Name")]
    [String]
    $StgRG,

    [Parameter(Mandatory=$true,
    HelpMessage="Add Storage Account blob container Name")]
    [String]
    $StgContainerName
)

# Variables that can be adjusted based in your needs.
# Filter1 gets inner and outer IPSec Tunnel traffic (Default filter used by this script).
$Filter1 = "{`"TracingFlags`": 11,`"MaxPacketBufferSize`": 120,`"MaxFileSize`": 500,`"Filters`" :[{`"CaptureSingleDirectionTrafficOnly`": false}]}" 
# Filter2 shows how to filter between IPs or Subnets.
$Filter2 = "{`"TracingFlags`": 11,`"MaxPacketBufferSize`": 120,`"MaxFileSize`": 500,`"Filters`" :[{`"SourceSubnets`":[`"10.60.4.4/32`",`"10.200.1.5/32`"],`"DestinationSubnets`":[`"10.60.4.4/32`",`"10.200.1.5/32`"],`"CaptureSingleDirectionTrafficOnly`": false}]}" # This filter gets inner and outer IPSec Tunnel traffic.
<# Few notes about filters: 
1) MaxPacketBufferSize it takes first 120 bytes. You can change it to 1500 to get full packet size in case you need to investigate the payload.
2) MaxFileSize is 500 MB.
#>
$startTime = Get-Date
$EndTime = $startTime.AddDays(1)
$ctx = (Get-AzStorageAccount -Name $StgName -ResourceGroupName $StgRG).Context
$SAStokenURL = New-AzStorageContainerSASToken  -Context $ctx -Container $StgContainerName -Permission rwd -ExpiryTime $EndTime -FullUri

# Get full VPN Gateway Capture
## Start Packet Capture
Write-Host "Please wait, starting VPN Gateway packet capture..." -ForegroundColor Yellow
Start-AzVpnGatewayPacketCapture -ResourceGroupName $vWANGWRG -Name $vWANGWName -FilterData $Filter1

## Stop Packet Capture
Write-Host -NoNewLine 'Reproduce your issue and press any key to stop to capture...' -ForegroundColor Yellow;
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
Write-Host ""
Write-Host "Please wait, stopping VPN Gateway packet capture..." -ForegroundColor Red

Stop-AzVpnGatewayPacketCapture -ResourceGroupName $vWANGWRG -Name $vWANGWName -SasUrl $SAStokenURL

## Retrieve your Packet Captures
Write-Host "Retrieve packet captures using Storage Explorer over:" -ForegroundColor Yellow
Write-Host "Storage account:" $StgName
Write-Host "Blob container :" $StgContainerName