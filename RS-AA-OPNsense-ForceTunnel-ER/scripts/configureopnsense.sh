#!/bin/sh
#OPNSense default configuration template
fetch https://raw.githubusercontent.com/dmauser/opnazure/master/scripts/$1
cp $1 /usr/local/etc/config.xml

# 1. Package to get root certificate bundle from the Mozilla Project (FreeBSD)
# 2. Install bash to support Azure Backup integration
env ASSUME_ALWAYS_YES=YES pkg install ca_root_nss && pkg install -y bash 

#Dowload OPNSense Bootstrap and Permit Root Remote Login
fetch https://raw.githubusercontent.com/opnsense/update/master/bootstrap/opnsense-bootstrap.sh
sed -i "" 's/#PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config

#OPNSense
sed -i "" "s/reboot/shutdown -r +15/g" opnsense-bootstrap.sh
sh ./opnsense-bootstrap.sh -y
#Add support to LB VIP probe
fetch https://raw.githubusercontent.com/dmauser/Lab/master/RS-AA-OPNsense-ForceTunnel-ER/scripts/lb-conf.sh
sh ./lb-conf.sh

