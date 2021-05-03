# Migrating Spoke VNET to Azure Virtual WAN Hub

## Concepts

![Migration flow](./SPK-Migrate-to-VWANHUB.png)

## Sample script

```bash
# Pre-Requisite
az extension add --name virtual-wan
az extension update --name virtual-wan

# 1) Define Variables (Resource Groups, SpokeVNET, VWANHUB, VWAN VNET Connnection Name)
# SpokeVNET variables – replace <> with your values.
SPKRG='' #Spoke VNET Resource Group
SPKVNETName='' #Spoke VNET Name
vnetid=$(az network vnet show -g $SPKRG -n $SPKVNETName --query id --out tsv) #Spoke VNET ResourceID to be migrated to vWAN and used in step 3.
SPKPeeringName='' #Name of current peering using UseRemoteGateways=True that is connected to original HUB.
# vWAN HUB variables
VWANRG='' #vWAN Hub Resource Group Name
VHUB='' #vWAN Hub Name

# 2) Set UseRemoteGateways Gateways to false 
az network vnet peering update -g $SPKRG -n $SPKPeeringName --vnet-name $SPKVNETName --set UseRemoteGateways=False

# 3) Configure VWAN HUB Virtual Network Connection.
#Note: For simplification of the process $SPKVNETName is used as connection Name for VHUB. If you need specify a new name just add a new variable for that.
az network vhub connection create -g $VWANRG -n $SPKVNETName --vhub-name $VHUB --remote-vnet $vnetid

# <Migration completes here>

# ROLL BACK (Remove VHUB VNET Connection and re-enables original peering to UseRemoteGateways to true)
# ***NOTE***: Use only if previous steps did not work and you want to revert traffic back to original HUB.
az network vhub connection delete -g $VWANRG -n $SPKVNETName --vhub-name $VHUB
az network vnet peering update -g $SPKRG -n $SPKPeeringName --vnet-name $SPKVNETName --set UseRemoteGateways=True
```

## Lab

