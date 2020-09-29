#!/bin/bash

# 1 uninstall NetworkManager
# 2 run this script, then add this to your /etc/networking/interface file
#auto enp0s3
#iface enp0s3 inet dhcp
#  pre-up iptables-restore < /etc/iptables.rules
#  pre-up ip6tables-restore < /etc/ip6tables.rules

# Flush
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X

# Flush V6
ip6tables -t nat -F
ip6tables -t mangle -F
ip6tables -F
ip6tables -X

# allow Localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# allow Localhost V6
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT

# Make sure you can communicate with any DHCP server
iptables -A OUTPUT -d 255.255.255.255 -j ACCEPT
iptables -A INPUT -s 255.255.255.255 -j ACCEPT

# Make sure that you can communicate within your own network if Private Network option is enabled
iptables -A INPUT -s 192.168.1.0/16 -d 192.168.1.0/16 -j ACCEPT
iptables -A OUTPUT -s 192.168.1.0/16 -d 192.168.1.0/16 -j ACCEPT
#iptables -A INPUT -s 10.0.0.0/8 -d 10.0.0.0/8 -j ACCEPT
#iptables -A OUTPUT -s 10.0.0.0/8 -d 10.0.0.0/8 -j ACCEPT
#iptables -A INPUT -s 172.16.0.0/12 -d 172.16.0.0/12 -j ACCEPT
#iptables -A OUTPUT -s 172.16.0.0/12 -d 172.16.0.0/12 -j ACCEPT

# Allow incoming pings if Ping option is enabled
#iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# Allow established sessions to receive traffic:
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow TUN
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A OUTPUT -o tun+ -j ACCEPT

# Block All
iptables -A OUTPUT -j DROP
iptables -A INPUT -j DROP
iptables -A FORWARD -j DROP

# Block All V6
ip6tables -A OUTPUT -j DROP
ip6tables -A INPUT -j DROP
ip6tables -A FORWARD -j DROP

# allow VPN connection
iptables -I OUTPUT 1 -p udp --destination-port 1198 -m comment --comment "Allow VPN connection" -j ACCEPT

echo "saving"

iptables-save > /etc/iptables.rules
ip6tables-save > /etc/ip6tables.rules

echo "done"
