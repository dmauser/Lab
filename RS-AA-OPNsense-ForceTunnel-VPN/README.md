# Forced Tunneling of Internet traffic through Active-Active OPNsense Firewalls using Azure Route Server (VPN)

## Notice: This lab is still under development 

**In this article**
- [Introduction](#Introduction)
- [Configuration](#Configuration)
- [OPNsense configuration](#OPNsense-configuration)
- [Routing validation](#Routing-validation)
- [Connectivity validation](#Connectivity-validation)
- [Close out](#Close-out)

## Introduction

The main goal of this article is to demonstrate how to use Azure for Internet Breakout (force tunnel of the Internet) to On-premises network. This article is divided into the following scenarios by Forced Tunneling of Internet traffic through Active-Active NVAs.

1 - On-premises using Site-to-Site IPSec VPN
2 - User VPN connecting to Azure Virtual Network Gateway (also known as Point to Site VPN)

In general, this article describes how this force tunneling is configured in an Azure Hub-Spoke with a pair of Active-Active OPNsense Firewall Network Virtual Appliances (NVAs), each and an Internal Load Balancer (ILB) directing East-West traffic. Specifically for both VPN scenarios (Site to Site and Point to Site), by configuring the OPNsense to originate the default route (0/0), and by introducing Azure Route Server to reflect this default route, customers will be able to force On-premises remote site and user VPN to use Internet-bound traffic through the OPNsense firewalls.

In case you want to validate this Lab over ExpressRoute please consult this Lab: 

>**Cost**: estimated daily cost for this LAB is around $8 US dollars (USD)

![Use Case for Force Tunneling](./images/main-use-case-default-internet.png)


## Special considerations for Azure VPN Gateway

There are two special considerations for this Lab to work properly with Azure VPN Gateway.

1- You have to provision your VPN Gateway as Active/Active to work with Azure Route Server. More information: [About Azure Route Server (Preview) support for ExpressRoute and Azure VPN](https://docs.microsoft.com/en-us/azure/route-server/expressroute-vpn-support)
2 - Azure VPN Gateway does not propagate default route (0.0.0.0/0) remote branches connected via S2S VPN as well P2S VPN. In that case you need to split 0.0.0.0/0 in two networks 0.0.0.0/1 (0/1) and 128.0.0.0/1 (128/1).

## Concepts

1. A default route (0/1 and 128/1) MUST be propagated via BGP to On-premises across Azure VPN Gateway, to attract Internet traffic from On-premises through Azure. 
2. Both OPNsense NVAs (Active-Active) will originate the default route by redistributing the static route 0/1 and 128/1 (default route) into BGP.
3. Azure Route Server will learn this default route sourced by OPNsense through eBGP.
4. Azure VPN Gateway will learn this default route through iBGP peering with the Route Server. Azure VPN Gateway will see Next Hop as the OPNsense NVAs’ peer IP, not Route Server.
5. Azure VPN Gateway will propagate the default route to On-premises via IPSec tunnel.
6. On-premises thus learns of default route from Azure, and will route Internet traffic to Azure and the OPNsense NVAs.
7. In Active-Active OPNsense design, Protected subnet in VNET Hub and Spoke subnets will have UDR pointing to ILB, for either East-West or North-South traffic. The use of the Load Balancer does NOT change for this Active-Active OPNsense configuration. Furthermore, User-Defined Routes are still required at GatewaySubnet pointing to ILB to ensure sticky, symmetrical flow path for East-West traffic.

>**REMEMBER** when propagating 0/1 and 128/1 routes can have unintended consequences, as you are announcing to the world "comes as me as default route!"

## Configuration

You can deploy this scenario by using the CLI scripts below either by using Bash over Windows (WSL2) or cloud shell CLI.

**Define Variables**

Check the commented lines to replace based on your environment requirements.

```Bash
Under Construction
```

**Create VNETs and Subnets**

```Bash
#Build Networks Hub and Spoke Networks
# HUB VNET

```

**Create VNET Peerings between HUB and Spokes**

```Bash

```

**(Optional) UDR to restrict SSH access to Azure VMs from your Public IP only**

Alternatively you can deploy Azure Bastion on HUB VNET to access Azure VMs and remove Hub and spoke VMs Public IPs.

```Bash

```

**Create ExpressRoute Gateway**

```bash

```

**Deploy OPNsense behind Load Balancer**

1) Create NVA ILB

```Bash

```

2) Deploy both OPNsense NVAs

```Bash

```

3) Attach OPNsense NVAs behind LB

```Bash

```

4) Configure UDR to disable BGP propagation external NVA NICs. Disable BGP propagation on External Subnet (Reason: because NVAs learns Route Server routes and insert them OPN NVAs on external nic causing route loops).

```Bash

```

**Deploy Azure VMs on Hub and both Spoke VNETs**

1) Set username and password variables via prompt.
```bash

```
2) Create Public IP, NICs and VMs for each VNET

```bash
```

3) Configure UDR to VMs use NVA for Internet (default route) and specific Spoke VNET CIDRs to force east-west traffic via NVA Load Balancer. It also creates Public IP exception for SSH access.

```Bash
```

4) UDR on GatewaySubnet to allow symmetric traffic between On-premises and VMs in Spoke VNETs.

```bash

```

**Deploy Route Server**

1) Check if ER Gateway is Succeeded (provisioned) before creating Route Server

```Bash
```

2) Create Route Server

```Bash

```

3) Build Route Server BGP Peering with NVAs

```Bash

```

4) Allow Route Server to propagate NVA routes over branch (ExpressRoute).

```Bash
```

**Create VPN Gateway connection to On-premises**


```Bash
```

## OPNsense configuration

### Obtain Pulic IPs
```Bash
echo opn-nva1 - $(az network public-ip show --name OPN-NVA1-PublicIP --resource-group $rg -o tsv --query "ipAddress" -o tsv) \
opn-nva2 - $(az network public-ip show --name OPN-NVA2-PublicIP --resource-group $rg -o tsv --query "ipAddress" -o tsv) 
```

### Configure OPNsense via Web interface

Access both Public IPs and use default username and password (root/opnsense). Than, configure the following:

**1) Lobby\Password** 

**Please, change the default password**. It is recommended set the same password for both NVAs to facilitate configuration replication used later in the guide.

**2) System\Firmware\Plugins**

Add **os-frr** (The FRRouting Protocol Suite) plugin that is going to be used for BGP.

### Steps below on opn-nva1 only  

On opn-nva1 only make the following changes. Later those changes will replicated automatically to opn-nva2.

Here is a table with all settings to be configured:

**1) System Gateways and Routes**

| Section | Setting  | Value   |
|---|---|---|
|  **System: Gateways: Single** || And new Gateway |
||  Name | LANGW   |
|| Interface  | LAN   |
|| IP address | 172.16.136.65 |
|  **System: Routes: Configuration** || Add rules for RF1918 address spaces |
||  Network Address | 192.168.0.0/16  |
|| Gateway  | LANGW - 172.16.136.65   |
||  Network Address | 172.16.0.0/12   |
|| Gateway  | LANGW - 172.16.136.65   |
||  Network Address | 10.0.0.0/8   |
|| Gateway  | LANGW - 172.16.136.65   |

Final routes should look like:

![System: Routes: Configuration](./images/opn-system-routes.png)

**2) Firewall: NAT: Outbound**

Change to mode to: **Hybrid outbound NAT rule generation
(automatically generated rules are applied after manual rules)** and **Apply Changes**.

Click **Add** Firewall: NAT: Outbound rule and leave all default settings and hit **Save**. That will allow anything that goes out WAN interface use source NAT (SNAT).

![Firewall: NAT: Outbound](./images/opn-firewall-nat-outbound.png)

**Note:** Don't forget to apply changes.

**3) Firewall: Rules: LAN**

Modify existing rule to allow any traffic. Edit and change **Source** from **LAN net** to **Any** and save.

![Firewall: Rules: LAN*](./images/opn-firewall-rules-lan.png)

**4) Routing: General**

| Section | Setting  | Value   |
|---|---|---|
|  **Routing: General** |
||  Enable | Checked (Save)   |
|  **Routing: BGP (General Tab)** ||  |
|| Enable | Checked   |
|| BGP AS Number | 65002 |
|| Network | 0.0.0.0/0  |
|  **Routing: BGP (Neighbors Tab)** || Add an entry for each Route Server IP |
|| Peer-IP | 172.16.139.4 **(*)**  |
|| Remote AS | 65515 |
|| Multi-Hop | Checked  |
|| Peer-IP | 172.16.139.5   |
|| Remote AS | 65515 |
|| Multi-Hop | Checked  |

**Note(1)** Obtain Route Server IPs by running this CLI command:

```Bash
az network routeserver list --resource-group $rg --query '{IPs:[].virtualRouterIps}'
```

**Note(2):** Go back to **General Tab** and hit **Save**.

**5) Routing: Diagnostics: General (Running config tab)**

Ensure BGP configuration is correct. It should match the config below:

```Text
Current configuration:
!
frr version 7.4
frr defaults traditional
hostname OPNsense.localhost
log syslog critical
!
router bgp 65002
 no bgp ebgp-requires-policy
 neighbor 172.16.139.4 remote-as 65515
 neighbor 172.16.139.4 ebgp-multihop 255
 neighbor 172.16.139.5 remote-as 65515
 neighbor 172.16.139.5 ebgp-multihop 255
 !
 address-family ipv4 unicast
  network 0.0.0.0/0
 exit-address-family
!
line vty
!
end
```

**6) System: High Availability: Settings**

| Setting  | Value  |
|---|---|
| Synchronize Config to IP | 	172.16.136.70 **(*)** |
| Remote System Username | root |
| Remote System Password | opnsense (or newer OPNsense password) |
| Dashboard | Checked |
| Firewall Rules | Checked |
| NAT | Checked |
| Static Routes | Checked |
| FRR | Checked |

**(Note):** Get LAN IP for opn-nva2 by running the following CLI commands:
```bash
#opn-nva2
az network nic show -g $rg --name $nva2-Trusted-nic --query "ipConfigurations[].privateIpAddress" -o tsv

```

On the same screen click **Perform synchronization** that you can find besides: Configuration Synchronization Settings (XMLRPC Sync). That should bring you to: System: High Availability: Status screen.
Click in Synchronize to push configuration from opn-nva1 to opn-nva2 as shown:

![Firewall: NAT: Outbound](./images/opn-system-ha-status.png)

## Routing validation

### OPNsense

**BGP Status (Routing: Diagnostics: BGP - Summary Tab)**
```Bash
IPv4 Unicast Summary:
BGP router identifier 172.16.136.69, local AS number 65002 vrf-id 0
BGP table version 3
RIB entries 2, using 384 bytes of memory
Peers 2, using 29 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt
172.16.139.4    4      65515         7         8        0    0    0 00:04:01            1        2
172.16.139.5    4      65515         7         8        0    0    0 00:04:02            1        2

Total number of neighbors 2
```

**Azure Hub and Spoke VMs Effective Routes**

```Bash
echo $hubname-vm - $(az network nic show --resource-group $rg -n $hubname-vm-nic --query "ipConfigurations[].privateIpAddress" -o tsv)
az network nic show-effective-route-table --resource-group $rg -n $hubname-vm-nic -o table

echo $spoke1name-vm - $(az network nic show --resource-group $rg -n $spoke1name-vm-nic --query "ipConfigurations[].privateIpAddress" -o tsv)
az network nic show-effective-route-table --resource-group $rg -n $spoke1name-vm-nic -o table

echo $spoke2name-vm - $(az network nic show --resource-group $rg -n $spoke2name-vm-nic --query "ipConfigurations[].privateIpAddress" -o tsv)
az network nic show-effective-route-table --resource-group $rg -n $spoke2name-vm-nic -o table
```

Expected output:

![Azure VMs effective route table](./images/vm-effective-route-table.png)

**Check ER Gateway learned and advertised routes**

```Bash
# BGP peer status
az network vnet-gateway list-bgp-peer-status -g $rg -n $hubname-ergw -o table

# Adverstised routes
ips=$(az network vnet-gateway list-bgp-peer-status -g $rg -n $hubname-ergw --query 'value[].{ip:neighbor}' -o tsv)
array=($ips)
for ip in "${array[@]}"
  do
  echo Advertised routes to peer $ip
  az network vnet-gateway list-advertised-routes -g $rg -n $hubname-ergw -o table --peer $(az network vnet-gateway list-bgp-peer-status -g $rg -n $hubname-ergw --query 'value[1].{ip:neighbor}' -o tsv)
  done

# Learned routes
az network vnet-gateway list-learned-routes -g $rg -n $hubname-ergw -o table
```

Expected output:

![Azure VMs effective route table](./images/expressroute-gateway-output.png)

**Check Route Server (RS) learned and advertised routes**

```Bash
# BGP peer status
az network routeserver peering list --resource-group $rg --routeserver $hubname-rs -o table 
# Adverstised routes
array=($nva1 $nva2)
for nva in "${array[@]}"
  do
  echo Advertised routes from RS $hubname-rs to $nva
  az network routeserver peering list-advertised-routes --resource-group $rg \
  --name $nva \
  --routeserver $hubname-rs 
  done

# Learned routes
array=($nva1 $nva2)
for nva in "${array[@]}"
  do
  echo Learned routes on RS $hubname-rs from $nva
  az network routeserver peering list-learned-routes --resource-group $rg \
  --name $nva \
  --routeserver $hubname-rs 
  done
```

Output example of learned routes on both Route Server instances from opn-nva1:

![Route Server learned routes](./images/route-server-learned-routes.png)

**ExpressRoute circuit route table**

```Bash
# Primary Circuit
az network express-route list-route-tables --path primary -n $ercircuit -g $errg  --peering-name AzurePrivatePeering -o table
# Secondary Circuit
az network express-route list-route-tables --path secondary -n $ercircuit -g $errg  --peering-name AzurePrivatePeering -o table
```

Example of expected output of primary ExpressRoute Circuit:

![Route Server learned routes](./images/expressroute-circuit-output.png
)

.12 and .13 are the ExpressRoute Gateways (AS 65515) listed as next hop and OPN-NVA (AS 65002) as source of 0.0.0.0/0 route.

## Connectivity validation

Note that NSG locks down access only from Public IP parsed during its creation process.

```Bash
#VMs Public IPs
echo $hubname-vm - $(az network public-ip show --name $hubname-vm-pip --resource-group $rg --query "ipAddress" -o tsv) \
$spoke1name-vm - $(az network public-ip show --name $spoke1name-vm-pip --resource-group $rg -o tsv --query "ipAddress" -o tsv) \
$spoke2name-vm - $(az network public-ip show --name $spoke2name-vm-pip --resource-group $rg -o tsv --query "ipAddress" -o tsv)

## OPN NVAs Public IPs
echo $nva1 - $(az network public-ip show --name $nva1-PublicIP --resource-group $rg -o tsv --query "ipAddress" -o tsv) \
$nva2 - $(az network public-ip show --name $nva2-PublicIP --resource-group $rg -o tsv --query "ipAddress" -o tsv) 
```

For the context of this LAB my OPN nvas public IPs are:

| OPNsense name | Public IP Address |
|---|---|
| opn-nva1 | 20.189.31.180
| opn-nva2 | 20.189.31.196

### Azure VMs

Below is the output when an Internet access is attempted from hub-vm (IP 172.16.136.132) and when attempt to access ifconfig.io and ipconfig.io. Two different website are used because that required to trigger Load Balancer to process a five-tuple hash and balance traffic between both NVAs, for more information consult: [Azure Load Balancer distribution modes](https://docs.microsoft.com/en-us/azure/load-balancer/distribution-mode-concepts).

![Hub-vm outbound Internet traffic](./images/hub-vm-out.png)

You can repeat the same steps on Spoke VMs and you should expect similar results.

### On-Premises

Because now 0/0 (default route) is propagated to On-Premises from OPNsense via Azure Route Server and ExpressRoute you can also see the same behavior. In this case, On-premises VM local IP is 192.168.1.3 and is also going out to the Internet via both OPNsense NVAs in Azure.

![On-premises-vm outbound Internet traffic](./images/onprem-vm-out.png)

### Consideration on Internet (default route) traffic patterns

It is important to note that traffic from Azure VMs (HUB and Spokes) versus On-Premises via ExpressRoute. While Azure VMs use UDR 0/0 (default route) to NVAs Internal Load Balancer (ILB), traffic from On-Premises will enter the Hub-VNET via ExpressRoute Gateway. Note there is no UDR set at GatewaySubnet to 0/0 next-hop NVAs ILB because that is currently not supported. Therefore, traffic leaving ExpressRoute Gateway to send traffic directly to each one of the OPNsense NVA instances and BGP will load share the traffic by leveraging ECMP.

On the diagram below the green dotted lines show traffic flow to Internet via ILB from Azure VMs (Hub and Spokes) and black dotted lines show traffic from On-premises.

![Internet traffic pattern](./images/internet-traffic-pattern.png)

## Close out

In this lab, you learned how to properly configure default route(0/0) propagation to On-premises using Active-Active OPNsense NVAs via eBGP and Azure Route Server. This solution allows Internet Breakout in Azure for on-premises and VMs on VNETs (Hub and Spokes).

### Final task:  remove all resources

Run the following CLI commands:

```Bash
az network routeserver peering delete --resource-group $rg --routeserver $hubname-rs --name $nva1 --yes
az network routeserver peering delete --resource-group $rg --routeserver $hubname-rs --name $nva2 --yes
az network routeserver delete -g $rg -n $hubname-rs --yes
az group delete -g $rg --no-wait --yes
```
