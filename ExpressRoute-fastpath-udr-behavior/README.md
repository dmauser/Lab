# UDR behavior when using ExpressRoute Fastpath

## Environment:

OnPrem - 10.40.0.0/20
Azure HUB - 10.50.0.0/20
	• NVA - 10.50.2.5 
	• VM - 10.50.4.4
Azure Spoke VNET - 10.50.16.0/20
	• VM - 10.50.16.4

UDR added to ER GW Subnet
	- 10.50.4.0/24 - Next Hop 10.50.2.5
10.50.16.0/20 - Next Hop 10.50.2.5

## Observations

1) When assigning UDR on Gateway Subnet it will not turn off FastPath as whole.
2) UDR assigned on GW Subnet towards a Subnet address space under Hub VNET is ignored (Expected). I added UDR targeting a subnet /24 inside Hub VNET towards a NVA and it does not work. Traffic hits VM behind NVA directly.
3) UDR towards Spoke VNET using Hub NVA it works fine (Expected because Spoke VNET it will always goes over ER GW).
​4) Disabled Fast Path on (2) and  UDR works:

## Conclusion