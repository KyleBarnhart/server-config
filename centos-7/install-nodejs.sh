#!/bin/bash

curl -sL https://rpm.nodesource.com/setup | bash -
yum install -y nodejs

iptables -A INPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables-save > /etc/sysconfig/iptables
