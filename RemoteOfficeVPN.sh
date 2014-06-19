#!/bin/bash
BranchAddress="192.168.1.0/24"
BranchLoopback="192.168.100.1"
BranchVPNLocal="192.168.110.1"
RemoteVPNAddr="192.168.111.1"
RemoteHost="192.168.0.1"
SharedSecretKey="keykeykeykey"
HostName="BranchOffice01"
tls_ca_cert_file="/etc/openvpn/Branch01_ca.crt"
tls_cert_file="/etc/openvpn/Branch01_vpn1.crt"
tls_dh_file="/etc/openvpn/Branch01_dh1024.pem"
tls_key_file="/etc/openvpn/Branch01_vpn1.key"

RemoteNetwork="10.0.0.0"

cat << EOF > Node1.config

#set  interface  Addresses								
set interface ethernet eth0 address $BranchAddress			
								
#set  VPN Tunnel								
run generate openvpn key /config/auth/$HostNameVPNkey.psk				
run generate vpn rsa-key bits 2048 random /dev/urandom	
								
set interface openvpn vtun0 encryption aes256			
set interface openvpn vtun0 local-address $BranchVPNLocal			
set interface openvpn vtun0 mode site-to-site			
set interface openvpn vtun0 remote-address $RemoteVPNAddr			
set interface openvpn vtun0 remote-host $RemoteHost			
set interface openvpn vtun0 shared-secret-key-file $SharedSecretKey			
								
set interface openvpn vtun0 tls ca-cert-file $tls_ca_cert_file
set interface openvpn vtun0 tls cert-file $tls_cert_file		
set interface openvpn vtun0 tls dh-file $tls_dh_file		
set interface openvpn vtun0 tls key-file $tls_key_file	
								
#set  OSPF Stuff
set protocols ospf area 0 network 0.0.0.0/0		
set protocols ospf neighbor $RemoteVPNAddr				
set protocols ospf redistribute static				
set protocols ospf redistribute connected				

#set  Static Routes
set protocols static route $RemoteNetwork next-hop $RemoteVPNAddr
set protocols static route $RemoteVPNAddr next-hop $BranchVPNLocal
								
#set SSH								
set service ssh						

#set  System Stuff
set system host-name $HostName		
set system login user vyos authentication plaintext-password vyos	
								
#set  clustering							
set cluster pre-shared-secret asldhfuip893qy4btulg9f8sd					
set cluster interface eth0				
set cluster group cluster monitor $BranchAddress			
set cluster group cluster primary $HostName			
set cluster group cluster secondary $HostName-Bkup			
set cluster group cluster service $BranchAddress

EOF

scp 