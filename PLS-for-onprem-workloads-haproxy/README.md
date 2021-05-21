# Using Private Link Service to publish On-premises workloads (HA-Proxy)


## Concepts

This lab is based on the reference architecture: [Using Private Link Service for On-premises workloads](https://github.com/dmauser/PrivateLink/tree/master/PLS-for-Onprem-workloads) using HA-Proxy. This solution will fully build the solution on Provider side as shown in the diagram below. You have to create Private Endpoints on each on of the customer deployments.

Below some important details of each environment deployed:

### Provider

1. Virtual networks: provider-az-vnet (Azure - 192.168.0.0/24) and provider-onprem (emulated On-premises 192.168.0.0/24)
2. Virtual Machines: Provider-onprem-lxvm (with IP 192.168.1.4 and running Nginx) and Provider-az-lxvm (10.0.0.4).
3. VM Scale Set pls-ha-proxy using two instances inside haproxy subnet.
4. Internal load standard balancer pls-std-ilb (10.0.0.132).
5. Private Link Service pls-haproxy using 10.0.0.164 that is from subnet pls-nat-subnet.
6. VPN Gateways and connection between Azure and On-premises environment.

### Customer A and B

1. Virtual networks: cx(a/b)-az-vnet (Azure - 192.168.0.0/24) and cx(a/b)-onprem (emulated On-premises 192.168.0.0/24)
2. Virtual Machines: Provider-onprem-lxvm (with IP 192.168.1.4 and running Nginx) and Provider-az-lxvm (10.0.0.4).
3. VPN Gateways and connection between Azure and On-premises environment.

**Note:** that all three environments use the same address space which is another benefit of Private Link Service that has built-in NAT.

## Deploy this solution

Deploy three separated environments for Provider, Customer A and Customer B using the same:

### Deploy over Azure Portal (Arm Template)

The recommendation is to deploy them on separate Azure Subscriptions and Tenants but all enviroments can be deployed in single subscription.

### Deploy over CLI

#

## Solution diagram