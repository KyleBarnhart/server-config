#!/bin/bash

if [ "$#" -ne 2 ] || [ ${#1} -lt 1 ] || [ ${#2} -lt 1 ]
then
    echo 'Try "sh config-base.sh username password"'
    exit
fi

yum -y install epel-release
yum -y update
yum -y install sudo unzip vim wget httpd

# add user
/usr/sbin/groupadd $1
/usr/sbin/useradd $1 -g $1 -G wheel
echo "$2"|passwd --stdin $1
echo "$1        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/$1
chmod 0440 /etc/sudoers.d/$1
