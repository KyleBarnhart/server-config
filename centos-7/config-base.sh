#!/bin/bash

if [ "$#" -ne 2 ] || [ ${#1} -lt 1 ] || [ ${#2} -lt 1 ]
then
    echo 'Try "sh config-base.sh username password"'
    exit
fi

yum -y install epel-release
yum -y update
yum -y install iptables-services sudo unzip vim wget

# add user
/usr/sbin/groupadd $1
/usr/sbin/useradd $1 -g $1 -G wheel
echo "$2"|passwd --stdin $1
echo "$1        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/$1
chmod 0440 /etc/sudoers.d/$1

systemctl enable iptables
systemctl start iptables

# flush
iptables -F

# default: DROP
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# localhost: free pass!
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#  Allows incoming SSH connections
iptables -A INPUT -p tcp --dport 2200 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 2200 -m state --state ESTABLISHED -j ACCEPT

#  Allows outgoing SSH connections (disabled)
# iptables -A OUTPUT -p tcp --dport 2200 -m state --state NEW,ESTABLISHED -j ACCEPT
# iptables -A INPUT -p tcp --sport 2200 -m state --state ESTABLISHED -j ACCEPT

# allow outbound DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT

#  Allows outgoing HTTP connections
iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

#  Allows outgoing HTTPS connections
iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

iptables-save > /etc/sysconfig/iptables




